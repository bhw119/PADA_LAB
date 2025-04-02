import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

plt.rcParams['font.family'] = 'AppleGothic'  # macOS
plt.rcParams['axes.unicode_minus'] = False

# ✅ 데이터 불러오기
df = pd.read_csv("/Users/jungsujin/PADA_LAB/fit_results.csv")

# ✅ 박스플롯 그리기
plt.figure(figsize=(8, 6))
sns.boxplot(data=df, x='platform', y='CFI', palette='Set2')

plt.title("플랫폼별 CFI 분포")
plt.xlabel("플랫폼")
plt.ylabel("CFI (모형 적합도)")
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()

# ✅ 이미지로 저장
plt.savefig("platform_cfi_boxplot.png", dpi=300)
plt.show()