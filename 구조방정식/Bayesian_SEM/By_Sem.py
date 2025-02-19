import pymc as pm
import numpy as np
import pandas as pd
import arviz as az

# 데이터 불러오기
data = pd.read_csv("/Users/jungsujin/PADA_LAB/final_data/audible_sentiment.csv")  # 우선 스케일 전으로 돌려보기

# 데이터 전처리 (필요한 변수 추출)
X1 = data[['Title_Length', 'Text_Length']].values
X2 = data[['Flesch_Reading_Ease', 'Depth', 'Breadth', 'Valence', 'Arousal', 'Interaction']].values
Y = data['Helpfulness'].values

N = len(Y)  # 샘플 개수

# Bayesian SEM 모델 정의
with pm.Model() as bsem_model:
    # 잠재변수 (요인) 정의
    Factor0 = pm.Normal("Factor0", mu=0, sigma=1, shape=(N,))
    Factor1 = pm.Normal("Factor1", mu=0, sigma=1, shape=(N,))

    # 측정 방정식 (요인 적재값)
    lambda_0 = pm.Normal("lambda_0", mu=1, sigma=0.5, shape=X1.shape[1])
    lambda_1 = pm.Normal("lambda_1", mu=1, sigma=0.5, shape=X2.shape[1])

    # 측정모형 정의 (Factor0와 Factor1은 각 샘플에 대해 동일하게 적용)
    X1_obs = pm.Normal("X1_obs", mu=pm.math.dot(Factor0[:, None], lambda_0[None, :]), sigma=0.5, observed=X1)
    X2_obs = pm.Normal("X2_obs", mu=pm.math.dot(Factor1[:, None], lambda_1[None, :]), sigma=0.5, observed=X2)

    # Helpfulness에 대한 회귀 방정식
    beta_0 = pm.Normal("beta_0", mu=0, sigma=1)
    beta_1 = pm.Normal("beta_1", mu=0, sigma=1)
    sigma_Y = pm.HalfNormal("sigma_Y", sigma=1)

    mu_Y = beta_0 * Factor0 + beta_1 * Factor1
    Y_obs = pm.Normal("Y_obs", mu=mu_Y, sigma=sigma_Y, observed=Y)

    # 샘플링 (멀티프로세싱 비활성화, 자동 초기화 설정)
    trace = pm.sample(2000, return_inferencedata=True, cores=1, init='auto')

# 결과 확인
az.summary(trace)
az.plot_trace(trace)