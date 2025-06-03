import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ✅ 한글 폰트 설정 (Mac 기준)
plt.rcParams['font.family'] = 'AppleGothic'  # Mac에서 한글 폰트
plt.rcParams['axes.unicode_minus'] = False

# ✅ 데이터 불러오기
df = pd.read_csv("/Users/jungsujin/PADA_LAB/fit_results.csv")

# ✅ CFI 기준 Valence별 Top 5 모델 선택
top_models_by_latent = (
    df.sort_values(by='CFI', ascending=False)
      .groupby('Latent')
      .head(5)
      .copy()
)

# ✅ 구조명 지정 (사용자 정의 이름 부여)
structure_name_mapping = {
    "Systematic ~ Heuristic\nHelpfulness ~ Heuristic + Systematic": "구조 4",
    "Heuristic ~ Systematic\nHelpfulness ~ Heuristic + Systematic": "구조 5",
    "Helpfulness ~ Heuristic + Systematic": "구조 1",
    "Heuristic ~ Systematic\nHelpfulness ~ Heuristic": "구조 3",
    "Helpfulness ~ Heuristic": "구조 7",
    "Systematic ~ Heuristic\nHelpfulness ~ Systematic": "구조 2",
    "Helpfulness ~ Systematic": "구조 6"
}

# ✅ 구조명 붙이기
top_models_by_latent['Model_Label_KR'] = top_models_by_latent['Structure'].map(structure_name_mapping)
top_models_by_latent['Model_Label'] = top_models_by_latent['Latent'] + ' - ' + top_models_by_latent['Model_Label_KR']

# 누락 제거 후 정렬
plot_data = top_models_by_latent.dropna(subset=['Model_Label'])
sorted_data = plot_data.sort_values(by='CFI', ascending=True).copy()

# ✅ 시각화
plt.figure(figsize=(10, 8))
sns.scatterplot(
    data=sorted_data,
    x='CFI',
    y='Model_Label',
    hue='Latent',
    style='Latent',
    s=120
)

# 수치 라벨 추가
for _, row in sorted_data.iterrows():
    plt.text(
        row['CFI'] + 0.001,
        row['Model_Label'],
        f"{row['CFI']:.3f}",
        va='center',
        fontsize=9
    )

plt.xlabel("CFI")
plt.ylabel("모델")
plt.title("Valence 종류별 Top 5 모델의 CFI (구조명 기준)")
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()

# ✅ 저장
plt.savefig("valence_top5_cfi_named.png", dpi=300)
plt.show()