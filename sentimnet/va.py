from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import re
import string

class va_scorer:

    def __init__(self, vad_lexicon_path):
        """
        VAD Lexicon을 로드하여 초기화

        Args:
            vad_lexicon_path (str): VAD Lexicon 파일 경로
        """
        self.vad_dict = {}
        self._load_lexicon(vad_lexicon_path)

    def _load_lexicon(self, file_path):
        """VAD Lexicon 파일을 읽어 딕셔너리로 저장"""
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                parts = line.strip().split()
                if len(parts) == 4:  # 단어와 3개의 점수가 있는지 확인
                    word = parts[0]
                    scores = [float(score) for score in parts[1:]]
                    self.vad_dict[word] = {
                        'valence': scores[0],
                        'arousal': scores[1],
                        'dominance': scores[2]
                    }

    def process_text(self, text):
        # 소문자 변환
        text = text.lower()

        # 문장부호 제거
        text = text.translate(str.maketrans('', '', string.punctuation))

        # 숫자 제거
        text = re.sub(r'\d+', '', text)

        # 토큰화
        tokens = word_tokenize(text)

        # 영어 불용어 제거
        stop_words = set(stopwords.words('english'))
        tokens = [token for token in tokens if token not in stop_words]

        # 단어 원형화
        lemmatizer = WordNetLemmatizer()
        lemmatized_tokens = [lemmatizer.lemmatize(token) for token in tokens]

        return lemmatized_tokens

    def get_vad_scores(self, word):
        """
        단어에 대한 VAD 점수를 반환

        Args:
            word (str): 검색할 단어

        Returns:
            dict: VAD 점수들을 포함한 딕셔너리 또는 None
        """
        return self.vad_dict.get(word.lower())

    def get_4_scores(self, words, arousal_thresh, valence_thresh):
        num_of_words = 0
        p_a = 0
        p_d = 0
        n_a = 0
        n_d = 0

        for word in words:
            scores = self.get_vad_scores(word)
            if scores:
                num_of_words += 1
                valence = scores['valence']
                arousal = scores['arousal']
                if valence >= valence_thresh:
                    if arousal >= arousal_thresh:
                        p_a += valence - valence_thresh
                        p_a += arousal - arousal_thresh
                    else:
                        p_d += valence - valence_thresh
                        p_d += arousal_thresh - arousal
                else:
                    if arousal >= arousal_thresh:
                        n_a += valence_thresh - valence
                        n_a += arousal - arousal_thresh
                    else:
                        n_d += valence_thresh - valence
                        n_d += arousal_thresh - arousal
        return (
            round(p_a / num_of_words, 3),
            round(p_d / num_of_words, 3),
            round(n_a / num_of_words, 3),
            round(n_d / num_of_words, 3)
        )

    def get_sentiment_scores(self, text, arousal_thresh, valence_thresh):
        words = self.process_text(text)
        p_a, p_d, n_a, n_d = self.get_4_scores(words, arousal_thresh, valence_thresh)
        return p_a, p_d, n_a, n_d

    def print_each_score(self, text):
        tokend = va_scorer.process_text(text)
        print("token", tokend)
        print('---------------------')
        for word in tokend:
            scores = va_scorer.get_vad_scores(word)
            if scores:
                print(f"{word}:")
                print(f"Valence: {scores['valence']}")
                print(f"Arousal: {scores['arousal']}")
                # print(f"Dominance: {scores['dominance']}")
                print('---------------------')
            else:
                print(word, "does not exist in the lexicon")
                print('---------------------')



# 사용 예시
text = "The course is well paced and they get you comfortable with the topics even though we do not have any sort of prior exposure in this field. It is very good for the beginners who are new to this field"
text2 = "Information was well organized, easy to learn, and study. with frequent note writing, and some breaks . You can learn a good brief summary of what's to come, and what to research more in the future."
text3 = "A lot of explanations not provided! Too many peer-graded assignments, really disappointed!"

va_scorer = va_scorer('Bipolar_Lexicon.txt')
p_a, p_d, n_a, n_d = va_scorer.get_sentiment_scores(text, 0.5, 0.5)
print(p_a, p_d, n_a, n_d)
va_scorer.print_each_score(text)

# result = vad_scorer.process_text(text)
# # 단일 단어 검색
# word = "aardvark"
# scores = vad_scorer.get_vad_scores(word)
# if scores:
#     print(f"{word}:")
#     print(f"Valence: {scores['valence']}")
#     print(f"Arousal: {scores['arousal']}")
#     print(f"Dominance: {scores['dominance']}")
# else:
#     print(f"'{word}' not found in lexicon")
#
#
# # 여러 단어 검색
# batch_scores = vad_scorer.get_vad_scores_batch(result)
# for word, scores in batch_scores.items():
#     if scores:
#         print(f"\n{word}:")
#         print(f"Valence: {scores['valence']}")
#         print(f"Arousal: {scores['arousal']}")
#         print(f"Dominance: {scores['dominance']}")
