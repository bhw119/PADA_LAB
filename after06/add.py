import pandas as pd

# 원본 리뷰 데이터
audible_df = pd.read_csv('/Users/jungsujin/PADA_LAB/after06/audible.csv')

# 추가할 평점 데이터
rating_df = pd.read_csv('/Users/jungsujin/PADA_LAB/after06/audible_06_Rating.csv')

# 기준이 되는 4개 컬럼으로 merge 수행
merged_df = pd.merge(
    audible_df,
    rating_df[['Posted_Date', 'Rating', 'Title_Length', 'Text_Length',
               'Avg_Rating_Overall', 'Avg_Rating_Performance', 'Avg_Rating_Story']],
    on=['Posted_Date', 'Rating', 'Title_Length', 'Text_Length'],
    how='left'  # 원본 데이터 유지
)

# 결과 저장 (선택)
merged_df.to_csv('audible_merged.csv', index=False)