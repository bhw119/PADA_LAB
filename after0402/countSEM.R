# 필요한 라이브러리 로드
library(detectseparation)
library(dplyr)
library(AER)
library(lavaan)
library(pscl)
library(semPlot)
library(car)
library(semTools)
library(MASS)
library(gamlss)
library(scales)  # scale 함수용

# 데이터 불러오기
df_amazon <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/amazon_updated_0419.csv")
df_audible <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/audible_updated_0419.csv")
df_coursera <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/coursera_updated_0419.csv")
df_hotel <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/hotel_updated_0419.csv")

# 모든 수치형 변수에 standard scaling 적용 함수
scale_df <- function(df) {
  numeric_vars <- sapply(df, is.numeric)
  df[numeric_vars] <- scale(df[numeric_vars])
  return(df)
}

# 스케일링 적용
df_amazon <- scale_df(df_amazon)
df_audible <- scale_df(df_audible)
df_coursera <- scale_df(df_coursera)
df_hotel <- scale_df(df_hotel)

# SEM 모델 정의
models <- list(
  "amazon" = '
    system1 =~ Text_Length + Title_Length + Is_Photo + Deviation_Of_Star_Ratings
    system2 =~ Flesch_Reading_Ease + Depth + Breadth  + Arousal
    Helpfulness ~ system1+ system2
  ',
  "audible" = ' 
    system1 =~ Text_Length+ Title_Length + Deviation_Of_Star_Ratings
    system2 =~ Flesch_Reading_Ease + Depth + Breadth  + Arousal
    Helpfulness ~ system1+ system2
  ',
  "coursera" = ' 
    system1 =~ Text_Length  + Deviation_Of_Star_Ratings
    system2 =~ Flesch_Reading_Ease + Depth + Breadth  + Arousal
    Helpfulness ~ system1+ system2
  ',
  "hotel" = ' 
    system1 =~ Text_Length+ Title_Length+Is_Photo+ Deviation_Of_Star_Ratings
    system2 =~ Flesch_Reading_Ease + Depth + Breadth  + Arousal
    Helpfulness ~ system1+ system2'
)

# 분석 루프 시작
for (case_name in names(models)) {
  cat("\n===============================")
  cat("\n### Running", case_name, "###\n")
  df <- get(paste0("df_", case_name))
  model <- models[[case_name]]
  
  # SEM 적합
  fit <- sem(model, data = df, estimator = "MLR")
  print(summary(fit, standardized = TRUE, rsquare = TRUE))
  
  if (lavInspect(fit, "converged")) {
    print(fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr")))
  } else {
    stop("SEM 모델 수렴 실패")
  }

  # # 요인 적재량 및 부정 분산 확인
  # factor_loadings <- parameterEstimates(fit, standardized = TRUE)
  # print(factor_loadings)
  # print(
  #   factor_loadings %>%
  #     filter(op == "~~", lhs == rhs & (est < 0 | is.nan(est)))
  # )

  # # AVE / CR 계산
  # latent_vars <- c("system1", "system2")
  # AVE_CR <- data.frame(Variable = latent_vars, AVE = NA, CR = NA)

  # for (i in seq_along(latent_vars)) {
  #   items <- subset(factor_loadings, lhs == latent_vars[i] & op == "=~" & !is.na(std.all))
  #   if (nrow(items) > 0) {
  #     loadings <- items$std.all
  #     errors <- 1 - loadings^2
  #     AVE_CR$AVE[i] <- sum(loadings^2) / (sum(loadings^2) + sum(errors))
  #     AVE_CR$CR[i] <- (sum(loadings)^2) / ((sum(loadings)^2) + sum(errors))
  #   }
  # }
  # print(AVE_CR)

  # # 잠재 변수 저장
  # df$Factor1 <- lavPredict(fit)[, "system1"]
  # df$Factor2 <- lavPredict(fit)[, "system2"]

  # # ZINB 모델 적합
  # gp_model <- zeroinfl(Helpfulness ~ Factor1 + Factor2 | Factor1 + Factor2,
  #                      data = df, dist = "negbin", link = "logit")
  
  # # Zero-inflation 예측 확률 시각화
  # df$zi_prob <- predict(gp_model, type = "zero")
  # plot(df$Factor1, df$zi_prob,
  #      main = paste(case_name, "- Factor1 vs Zero Prob"),
  #      pch = 16, col = "blue")
  # plot(df$Factor2, df$zi_prob,
  #      main = paste(case_name, "- Factor2 vs Zero Prob"),
  #      pch = 16, col = "red")
  
  # # 모델 요약 및 평가 지표
  # print(summary(gp_model))
  # cat("AIC:", AIC(gp_model), "\n")
  # cat("BIC:", BIC(gp_model), "\n")
  # cat("Pseudo R-squared:\n")
  # print(pR2(gp_model))
}