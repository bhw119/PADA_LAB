# dplyr 설치 (최초 1회)
# 패키지 로드
library(detectseparation)
library(dplyr)
library(AER)
# 📦 필요한 라이브러리
library(lavaan)
library(pscl)
library(semPlot)
library(car)
library(semTools)
library(MASS)
library(gamlss)

  # 📁 데이터 불러오기
  df_amazon <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/amazon_updated_0419.csv")
  df_audible <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/audible_updated_0419.csv")
  df_coursera <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/coursera_updated_0419.csv")
  df_hotel <- read.csv("/Users/jungsujin/PADA_LAB/depthupdate/hotel_updated_0419.csv")
  #df_amazon <- read.csv("C:/Users/Administrator/Desktop/PADA_LAB/구조방정식/Count_SEM/scaled_data/Re_amazon_scaled.csv")
  #df_audible <- read.csv("C:/Users/Administrator/Desktop/PADA_LAB/구조방정식/Count_SEM/scaled_data/Re_audible_scaled.csv")
  #df_coursera <- read.csv("C:/Users/Administrator/Desktop/PADA_LAB/구조방정식/Count_SEM/scaled_data/Re_coursera_scaled.csv")
  #df_hotel <- read.csv("C:/Users/Administrator/Desktop/PADA_LAB/구조방정식/Count_SEM/scaled_data/Re_hotel_scaled.csv")
  
  # 🔧 SEM 모델 정의
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
  # 각 모델에 대해 반복 실행
  for (case_name in names(models)) {
    cat("\n===============================")
    cat("\n### Running", case_name, "###\n")
    df <- get(paste0("df_", case_name))
    model <- models[[case_name]]   
    # 🔍 SEM 적합
    fit <- sem(model, data = df, estimator = "MLR")
    print(summary(fit, standardized = TRUE, rsquare = TRUE))
    # ✅ 모델 적합도 확인
    if (lavInspect(fit, "converged")) {
      print(fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr")))
    } else {
      stop("SEM 모델 수렴 실패")
    }
    
  #📊 요인 적재량 확인
  factor_loadings <- parameterEstimates(fit, standardized = TRUE)
  print(factor_loadings)
  print(
    parameterEstimates(fit, standardized = TRUE) %>%
      filter(op == "~~", lhs == rhs & (est < 0 | is.nan(est)))
  )


    # 💡 AVE / CR 계산
    latent_vars <- c( "system1","system2")
    AVE_CR <- data.frame(Variable = latent_vars, AVE = NA, CR = NA)

    for (i in seq_along(latent_vars)) {
      items <- subset(factor_loadings, lhs == latent_vars[i] & op == "=~" & !is.na(std.all))
      if (nrow(items) > 0) {
        loadings <- items$std.all
        errors <- 1 - loadings^2
        AVE_CR$AVE[i] <- sum(loadings^2) / (sum(loadings^2) + sum(errors))
        AVE_CR$CR[i] <- (sum(loadings)^2) / ((sum(loadings)^2) + sum(errors))
      }
    }
    print(AVE_CR)
  
  # 📈 잠재 변수 저장
  # df$Factor1 <- lavPredict(fit)[, "system1"]
  # df$Factor2 <- lavPredict(fit)[, "system2"]
  # 
  # 
  # # 3. 정수 변환 (소수점 있을 경우)
  # 
  # # 💡 NB 모델 적합
  # gp_model <- zeroinfl(Helpfulness ~ Factor1 + Factor2 | Factor1 + Factor2, 
  #                          data = df, dist = "negbin", link = "logit")
    # 제로인플레이션 파트를 별도 로지스틱 회귀로 분리해서 확인
  # 새로운 변수: Helpfulness가 0인지 여부
# df$zi_prob <- predict(gp_model, type = "zero")

# plot(df$Factor1, df$zi_prob, 
#      main = paste(case_name, "- Factor1 vs Zero Prob"), 
#      pch = 16, col = "blue")
# 
# plot(df$Factor2, df$zi_prob, 
#      main = paste(case_name, "- Factor2 vs Zero Prob"), 
#      pch = 16, col = "red")
  # 📊 모델 요약
  #   print(summary(gp_model))
  #   AIC_value <- AIC(gp_model)
  #   BIC_value <- BIC(gp_model)
  #   cat("AIC:", AIC_value, "\n")
  #   cat("BIC:", BIC_value, "\n")
  # 
  # # 📈 Pseudo R² 계산 (McFadden's R²)
  # pseudo_r2_negbinom <- pR2(gp_model)
  # cat("Pseudo R-squared:\n")
  # print(pseudo_r2_negbinom)

  # 🔍 Dispersion 계산 (잔차 기반)
  }
