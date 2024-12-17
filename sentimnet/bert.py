# pip install torch transformers sentencepiece
from transformers import pipeline, AutoTokenizer
import torch
import pandas as pd
from tqdm import tqdm
import os
from collections import Counter


class SentimentAnalyzer:
    def __init__(self):
        device = "mps" if torch.backends.mps.is_available() else "cpu"
        self.model_name = "nlptown/bert-base-multilingual-uncased-sentiment"
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
        self.classifier = pipeline(
            "sentiment-analysis",
            model=self.model_name,
            tokenizer=self.tokenizer,
            return_all_scores=True,
            device=device
        )

    def get_sentiments(self, text):
        """연속형과 이산형 점수 모두 반환"""
        scores = self.classifier(text)[0]

        # 연속형 점수 계산 (가중 평균)
        weighted_score = sum(float(score['label'][0]) * score['score'] for score in scores)
        continuous_score = round(weighted_score, 3)

        # 이산형 점수 계산 (가장 높은 확률의 별점)
        discrete_label = max(scores, key=lambda x: x['score'])['label']
        discrete_score = int(discrete_label[0])
        discrete_confidence = round(max(scores, key=lambda x: x['score'])['score'], 3)

        return continuous_score, discrete_score, discrete_confidence

    def analyze_long_text(self, text, max_tokens=450):
        # 원본 텍스트의 토큰 수 확인
        original_tokens = self.tokenizer.encode(text)
        was_split = len(original_tokens) > max_tokens

        if not was_split:
            # 토큰 수가 max_tokens 이하면 그대로 처리
            continuous_score, discrete_score, discrete_conf = self.get_sentiments(text)
            return continuous_score, discrete_score, discrete_conf, was_split

        # 토큰을 청크로 나누기
        chunks = []
        for i in range(0, len(original_tokens), max_tokens):
            chunk_tokens = original_tokens[i:i+max_tokens]
            chunk_text = self.tokenizer.decode(chunk_tokens)
            chunks.append(chunk_text)

        # 각 청크 분석
        continuous_scores = []
        discrete_scores = []
        confidence_scores = []

        for chunk in chunks:
            try:
                cont_score, disc_score, conf = self.get_sentiments(chunk)
                continuous_scores.append(cont_score)
                discrete_scores.append(disc_score)
                confidence_scores.append(conf)
            except Exception as e:
                print(f"Error processing chunk: {str(e)}")
                continue

        if not continuous_scores:  # 모든 청크가 실패한 경우
            raise Exception("Failed to process all chunks")

        # 평균 계산
        avg_continuous = round(sum(continuous_scores) / len(continuous_scores), 3)
        # 가장 빈번한 별점
        most_common_rating = Counter(discrete_scores).most_common(1)[0][0]
        # 평균 confidence
        avg_confidence = round(sum(confidence_scores) / len(confidence_scores), 3)

        return avg_continuous, most_common_rating, avg_confidence, was_split

    # 이하 기존 코드와 동일 (read_file, save_file, process_file 메서드)
    def read_file(self, file_path):
        file_extension = os.path.splitext(file_path)[1].lower()

        if file_extension == '.csv':
            encodings = ['utf-8', 'cp949', 'euc-kr', 'latin1']
            for encoding in encodings:
                try:
                    return pd.read_csv(file_path, encoding=encoding)
                except UnicodeDecodeError:
                    continue
                except Exception as e:
                    print(f"Error with {encoding} encoding: {str(e)}")
                    continue
            raise ValueError(f"Could not read file with any of the encodings: {encodings}")

        elif file_extension in ['.xlsx', '.xls']:
            return pd.read_excel(file_path)
        else:
            raise ValueError(f"Unsupported file format: {file_extension}")

    def save_file(self, df, file_path):
        file_extension = os.path.splitext(file_path)[1].lower()

        if file_extension == '.csv':
            df.to_csv(file_path, index=False)
        elif file_extension in ['.xlsx', '.xls']:
            df.to_excel(file_path, index=False)

    def process_file(self, file_path, text_column, batch_size=1000):
        df = self.read_file(file_path)
        total_rows = len(df)
        num_batches = (total_rows + batch_size - 1) // batch_size

        # 결과를 저장할 새로운 컬럼 생성
        df['sentiment_score_continuous'] = None  # 연속형 점수
        df['sentiment_score_discrete'] = None  # 이산형 점수 (별점)
        df['sentiment_confidence'] = None  # 이산형 점수의 확신도
        df['sentiment_error'] = None
        df['text_split'] = False  # 텍스트가 분할되었는지 표시

        print(f"\nMPS 사용 가능: {torch.backends.mps.is_available()}")
        print(f"현재 장치: {torch.device('mps' if torch.backends.mps.is_available() else 'cpu')}")
        print(f"총 {total_rows}개 데이터 처리 시작\n")

        for i in tqdm(range(0, total_rows, batch_size), desc="Processing"):
            batch_end = min(i + batch_size, total_rows)

            for idx in range(i, batch_end):
                try:
                    text = str(df.loc[idx, text_column])

                    if pd.isna(text) or text.strip() == '':
                        df.loc[idx, 'sentiment_score_continuous'] = None
                        df.loc[idx, 'sentiment_score_discrete'] = None
                        df.loc[idx, 'sentiment_confidence'] = None
                        df.loc[idx, 'sentiment_error'] = "Empty text"
                        df.loc[idx, 'text_split'] = False
                    else:
                        cont_score, disc_score, confidence, was_split = self.analyze_long_text(text)
                        df.loc[idx, 'sentiment_score_continuous'] = cont_score
                        df.loc[idx, 'sentiment_score_discrete'] = disc_score
                        df.loc[idx, 'sentiment_confidence'] = confidence
                        df.loc[idx, 'sentiment_error'] = None
                        df.loc[idx, 'text_split'] = was_split

                except Exception as e:
                    print(f"\nError processing row {idx}: {str(e)}")
                    df.loc[idx, 'sentiment_score_continuous'] = None
                    df.loc[idx, 'sentiment_score_discrete'] = None
                    df.loc[idx, 'sentiment_confidence'] = None
                    df.loc[idx, 'sentiment_error'] = str(e)
                    df.loc[idx, 'text_split'] = False

            # 현재까지의 결과 저장
            self.save_file(df, file_path)
            print(f"\n배치 {i // batch_size + 1}/{num_batches} 처리 완료")

        # 처리 결과 통계
        print("\n전체 처리 완료")
        print(f"에러 발생 건수: {df['sentiment_error'].notna().sum()}")
        print(f"분할 처리된 텍스트 건수: {df['text_split'].sum()}")
        print("\n별점 분포:")
        print(df['sentiment_score_discrete'].value_counts().sort_index())

        return df


if __name__ == "__main__":

    # 분석기 초기화
    analyzer = SentimentAnalyzer()

    df = analyzer.process_file(
        file_path='cs_reviews.csv',
        text_column='review_text',
        batch_size=1500
    )

    # 리소스 해제
    del analyzer.classifier
    del analyzer