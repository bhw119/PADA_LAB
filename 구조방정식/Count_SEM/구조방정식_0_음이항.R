library(lavaan)
library(pscl)
library(semPlot)
library(car)  # VIF 계산을 위해 추가

# 데이터 불러오기
df <- read.csv("C:/Users/Administrator/Desktop/PADA_LAB/구조방정식/Count_SEM/amazon_scaled.csv")

# SEM 모델 정의
model <- '
  system1 =~ Num_of_Ratings + Is_Photo + Title_Length + Text_Length + Price + Time_Lapsed
  system2 =~ Average_Rating + Deviation_Of_Star_Ratings + FOG_Index + Flesch_Reading_Ease + Depth + Breadth + Valence + Arousal + Interaction
'

# SEM 모델 적합
fit <- sem(model, data = df, estimator = "MLR")

# 📌 SEM 적합도 지표 확인
fit_measures <- fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr"))
print(fit_measures)

# 📌 요인 적재량(Factor Loadings)
factor_loadings <- parameterEstimates(fit, standardized = TRUE)
print(factor_loadings)

# 📌 AVE & CR 계산
latent_vars <- c("system1", "system2")
AVE_CR <- data.frame(Variable = latent_vars, AVE = NA, CR = NA)

for (i in 1:length(latent_vars)) {
  items <- subset(factor_loadings, lhs == latent_vars[i] & op == "=~")
  loadings <- items$std.all
  AVE_CR$AVE[i] <- mean(loadings^2)  # AVE
  AVE_CR$CR[i] <- sum(loadings)^2 / (sum(loadings)^2 + sum(items$se^2))  # CR
}

print(AVE_CR)

# 📌 잠재변수 추출
df$Factor1 <- lavPredict(fit)[, "system1"]
df$Factor2 <- lavPredict(fit)[, "system2"]
df$Helpfulness <- round(df$Helpfulness)  # 반올림
df$Helpfulness <- as.integer(df$Helpfulness)  # 정수 변환

# 📌 ZINB 모델 적합
zinb_model <- zeroinfl(Helpfulness ~ Factor1 + Factor2, 
                       data = df, 
                       dist = "negbin", 
                       link = "logit")

# 📌 ZINB 모델 적합도 평가
AIC_value <- AIC(zinb_model)
BIC_value <- BIC(zinb_model)
pseudo_r2 <- pR2(zinb_model)
logLik_value <- logLik(zinb_model)

# 📌 다중공선성 확인 (VIF)
vif_values <- vif(zinb_model)
print(vif_values)

# 📌 결과 출력
print(summary(zinb_model))
print(AIC_value)
print(BIC_value)
print(pseudo_r2)
print(logLik_value)

# 📌 SEM 시각화 (구조방정식 다이어그램)
semPaths(fit, "std", layout = "tree", whatLabels = "std", edge.label.cex = 1.2)
