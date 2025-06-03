import pandas as pd

# 데이터 불러오기
df_main = pd.read_csv("/Users/jungsujin/PADA_LAB/audible_0529.csv")
df_ref = pd.read_csv("/Users/jungsujin/PADA_LAB/audible_reviews1204 (1).csv")

# 필요한 열만 추출
ref_cols = ['Num_of_Ratings', 'Avg_Rating_Overall', 'Avg_Rating_Performance', 'Avg_Rating_Story']
df_ref = df_ref[ref_cols]

# 중복 제거 (Num_of_Ratings 기준으로 평균 별점 하나만 남기기)
df_ref = df_ref.drop_duplicates(subset='Num_of_Ratings')

# 메인 df에 값이 없을 때만 채워넣기
for col in ['Avg_Rating_Overall', 'Avg_Rating_Performance', 'Avg_Rating_Story']:
    if col not in df_main.columns:
        df_main[col] = None  # 열이 없다면 생성

# 값 채우기
for idx, row in df_main.iterrows():
    num_ratings = row['Num_of_Ratings']
    
    match = df_ref[df_ref['Num_of_Ratings'] == num_ratings]
    
    if not match.empty:
        match_row = match.iloc[0]  # 첫 매칭 값 사용

        for col in ['Avg_Rating_Overall', 'Avg_Rating_Performance', 'Avg_Rating_Story']:
            # 기존 값이 NaN 또는 비어 있을 경우만 채우기
            if pd.isna(row.get(col, None)):
                df_main.at[idx, col] = match_row[col]

# 결과 저장
df_main.to_csv("audible_0529_with_averages.csv", index=False)
print("✅ Num_of_Ratings 기준 평균 별점 병합 완료 → 'audible_0529_with_averages.csv'")