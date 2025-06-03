import pandas as pd

# 파일 경로 지정 (파일명을 본인에 맞게 수정)
file_path = "/Users/jungsujin/PADA_LAB/audible_reviews1204 (1).csv"

# CSV 불러오기
df = pd.read_csv(file_path)

# 별점 평균을 계산하는 함수
def calc_avg_rating(rating_str):
    counts = list(map(int, rating_str.split(',')))
    weights = [5, 4, 3, 2, 1]
    total_votes = sum(counts)
    if total_votes == 0:
        return 0.0
    weighted_sum = sum(w * c for w, c in zip(weights, counts))
    return round(weighted_sum / total_votes, 3)

# 평균 열 추가
df['Avg_Rating_Distribution'] = df['Rating_Distribution'].apply(calc_avg_rating)
df['Avg_Rating_Performance'] = df['Rating_of_Performance'].apply(calc_avg_rating)
df['Avg_Rating_Story'] = df['Rating_of_Story'].apply(calc_avg_rating)

# 원본 파일 덮어쓰기
df.to_csv(file_path, index=False)

print("✅ 평균 별점 열을 추가한 후, 원본 파일에 저장 완료!")