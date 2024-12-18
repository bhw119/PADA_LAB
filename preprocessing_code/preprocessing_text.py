import pandas as pd
import re

# CSV 파일 불러오기
pre_df = pd.read_csv("../audible_reviews1204_no_emojis.csv")

# 이모티콘만 제거하는 정규 표현식
def remove_emojis(text):
    # 정규 표현식으로 이모티콘만 제거
    return re.sub(r'[^\w\s,]', '', str(text))

# 'Review_Text'와 'Review Title' 열에서 이모티콘만 제거
pre_df['Review_Text'] = pre_df['Review_Text'].apply(remove_emojis)
pre_df['Review Title'] = pre_df['Review Title'].apply(remove_emojis)

# 영어 패턴 정의
english_pattern = r"^[A-Za-z0-9\s.,!?'\-\"()]+$"

# NaN 값이 있는 행 제거
pre_df = pre_df.dropna(subset=['Review_Text', 'Review Title'])

# 'Review_Text'와 'Review Title'이 영어로만 이루어진 행 필터링
pre_df = pre_df[
    pre_df['Review_Text'].str.match(english_pattern) & pre_df['Review Title'].str.match(english_pattern)
]

# 필터링된 데이터의 행 개수 출력
print(len(pre_df))

# 수정된 데이터를 새로운 CSV 파일로 저장
pre_df.to_csv("../audible_reviews1204_filtered.csv", index=False)

print("필터링된 파일이 저장되었습니다.")