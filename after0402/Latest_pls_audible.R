library(plspm)

# file 위치 설정
file <- "/Users/jungsujin/PADA_LAB/final_data/audible_sentiment.csv"

# CSV 파일 불러오기
data <- read.csv(file)

# 다양한 스케일링 함수 정의 ---------------------------------------
# 표준화 (Standardization)
standard_scaler <- function(x) {
  return(scale(x))
}

# Min-Max Scaling
minmax_scaler <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

# Robust Scaling (중앙값 기준, IQR 스케일링)
robust_scaler <- function(x) {
  med <- median(x, na.rm = TRUE)
  iqr <- IQR(x, na.rm = TRUE)
  
  if (iqr == 0) {
    return(rep(0, length(x)))  # 값이 다 같을 때 0으로 고정
  } else {
    return((x - med) / iqr)
  }
}

log_scaler <- function(x) {
  return(log(x + 1))
}

# 스케일링 선택 함수 ---------------------------------------------

scale_except <- function(df, col_exclude, method = "standard") {
  
  # 숫자형 열 선택
  num_cols <- names(df)[sapply(df, is.numeric)]
  cols_to_scale <- setdiff(num_cols, col_exclude)
  
  # 스케일링 메소드 선택
  scaler <- switch(method,
                   "standard" = standard_scaler,
                   "minmax" = minmax_scaler,
                   "robust" = robust_scaler,
                   "log" = log_scaler,
                   stop("Unknown scaling method!"))
  
  # 선택된 열에 스케일링 적용
  df[cols_to_scale] <- lapply(df[cols_to_scale], scaler)
  
  return(df)
}

# Abs(Valence)
#data$Valence <- abs(data$Valence)

# 각 데이터프레임에 함수 적용 (Helpfulness 열은 스케일링 제외)
data <- scale_except(data, col_exclude = c("Helpfulness", "Text_Length", "Title_Length"), method = "minmax")

# 위에 제외한 열들 스일링
data$Helpfulness <- log_scaler(data$Helpfulness)

data$Text_Length <- log_scaler(data$Text_Length)
data$Text_Length <- minmax_scaler(data$Text_Length)

data$Title_Length <- log_scaler(data$Title_Length)
data$Title_Length <- minmax_scaler(data$Title_Length)

# 상호작용항 생성
data$Depth <- data$Depth * -1
data$DepthXLength <- data$Depth * data$Text_Length
data$BreadthXLength <- data$Breadth * data$Text_Length
summary(data)

# 측정 모델의 모드 설정 Formative
modes <- c("B", "B", "B")

# 블록설정1_베이직 결과
# 구조 1, 2
blocks1 <- list(
  c("Text_Length", "Rating", "Title_Length"),  # heuristic
  c("Depth", "Breadth", "Arousal", "Flesch_Reading_Ease", "Deviation_Of_Star_Ratings", "Valence", "DepthXLength", "BreadthXLength"), #Systematic
  c("Helpfulness")   # helpfulness (단일 관측 변수)
)

# # 구조 3, 5
# blocks2 <- list(
#   c("DepthXLength", "BreadthXLength", "Valence", "Flesch_Reading_Ease", "Deviation_Of_Star_Ratings"), #Systematic
#   c("Text_Length", "Rating"),  # heuristic
#   c("Helpfulness")   # helpfulness (단일 관측 변수)
# )

# 구조 6
blocks3 <- list(
  c("Depth", "Breadth", "Arousal", "Flesch_Reading_Ease", "Deviation_Of_Star_Ratings", "Valence", "DepthXLength", "BreadthXLength"), #Systematic
  c("Helpfulness")   # helpfulness (단일 관측 변수)
)

# 구조 7
blocks4 <- list(
  c("Text_Length", "Rating", "Title_Length"),  # heuristic
  c("Helpfulness")   # helpfulness (단일 관측 변수)
)


# **************************************************구조 방정식 1***********************************************
# 구조 모델 정의 (잠재변수 간 관계 설정)
path_matrix <- rbind(
  c(0, 0, 0),
  c(0, 0, 0), 
  c(1, 1, 0)   # helpfulness (종속변수이므로 인풋 없음)
)

# 잠재 변수를 이름으로 매핑
colnames(path_matrix) <- rownames(path_matrix) <- c( "systematic","heuristic", "helpfulness")

# PLS-SEM 실행
pls_model <- plspm(
  Data = data,              # 데이터 입력
  path_matrix = path_matrix, # 구조 모델 정의
  blocks = blocks1,          # 측정 모델 정의
  modes = modes,             # Reflective 모델 지정
  scaled = FALSE,
)

summary(pls_model)

# **************************************************구조 방정식 2***********************************************
# 구조 모델 정의 (잠재변수 간 관계 설정)
path_matrix <- rbind(
  c(0, 0, 0),
  c(1, 0, 0), 
  c(0, 1, 0)   # helpfulness (종속변수이므로 인풋 없음)
)

# 잠재 변수를 이름으로 매핑
colnames(path_matrix) <- rownames(path_matrix) <- c("heuristic", "systematic", "helpfulness")

# PLS-SEM 실행
pls_model <- plspm(
  Data = data,              # 데이터 입력
  path_matrix = path_matrix, # 구조 모델 정의
  blocks = blocks1,          # 측정 모델 정의
  modes = modes,             # Reflective 모델 지정
  scaled = FALSE,
)

summary(pls_model)

# **************************************************구조 방정식 3***********************************************

# # 구조 모델 정의 (잠재변수 간 관계 설정)
# path_matrix <- rbind(
#   c(0, 0, 0),
#   c(1, 0, 0), 
#   c(0, 1, 0)   # helpfulness (종속변수이므로 인풋 없음)
# )

# # 잠재 변수를 이름으로 매핑
# colnames(path_matrix) <- rownames(path_matrix) <- c("systematic", "heuristic", "helpfulness")

# # PLS-SEM 실행
# pls_model <- plspm(
#   Data = data,              # 데이터 입력
#   path_matrix = path_matrix, # 구조 모델 정의
#   blocks = blocks2,          # 측정 모델 정의
#   modes = modes,             # Reflective 모델 지정
#   scaled = FALSE,
# )

# summary(pls_model)


# # **************************************************구조 방정식 5***********************************************
# # 구조 모델 정의 (잠재변수 간 관계 설정)
# path_matrix <- rbind(
#   c(0, 0, 0),
#   c(1, 0, 0), 
#   c(1, 1, 0)   # helpfulness (종속변수이므로 인풋 없음)
# )

# # 잠재 변수를 이름으로 매핑
# colnames(path_matrix) <- rownames(path_matrix) <- c("systematic", "heuristic", "helpfulness")

# # PLS-SEM 실행
# pls_model <- plspm(
#   Data = data,              # 데이터 입력
#   path_matrix = path_matrix, # 구조 모델 정의
#   blocks = blocks2,          # 측정 모델 정의
#   modes = modes,             
#   scaled = FALSE,
# )

# summary(pls_model)

# **************************************************구조 방정식 6***********************************************
# 측정 모델의 모드 설정 Formative
modes <- c("B", "B")


# 구조 모델 정의 (잠재변수 간 관계 설정)
# 여기서 "0"은 관계가 없음을 의미
path_matrix <- rbind(
  c(0, 0),
  c(1, 0)
)

# 잠재 변수를 이름으로 매핑
colnames(path_matrix) <- rownames(path_matrix) <- c("Systematic", "Helpfulness")

# PLS-SEM 실행
pls_model <- plspm(
  Data = data,              # 데이터 입력
  path_matrix = path_matrix, # 구조 모델 정의
  blocks = blocks3,          # 측정 모델 정의
  modes = modes,             # Reflective 모델 지정
  scaled = FALSE
)

# 분석 결과 요약
summary(pls_model)

# **************************************************구조 방정식 7***********************************************
# 측정 모델의 모드 설정 Formative
modes <- c("B", "B")


# 구조 모델 정의 (잠재변수 간 관계 설정)
# 여기서 "0"은 관계가 없음을 의미
path_matrix <- rbind(
  c(0, 0),
  c(1, 0)
)

# 잠재 변수를 이름으로 매핑
colnames(path_matrix) <- rownames(path_matrix) <- c("Heuristic", "Helpfulness")

# PLS-SEM 실행
pls_model <- plspm(
  Data = data,              # 데이터 입력
  path_matrix = path_matrix, # 구조 모델 정의
  blocks = blocks4,          # 측정 모델 정의
  modes = modes,             # Reflective 모델 지정
  scaled = FALSE
)

# 분석 결과 요약
summary(pls_model)
