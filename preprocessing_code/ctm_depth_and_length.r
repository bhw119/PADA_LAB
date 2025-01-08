# 필요한 라이브러리 로드
library(topicmodels)
library(tm)
library(Matrix)

# 데이터 불러오기
df <- read.csv("/Users/hyunwoo/Desktop/PADA/PADA_LAB/temp/sampled_hotel_1000_calculated.csv")

# 말뭉치 생성
corpus <- Corpus(VectorSource(df$Review_Text))

# 데이터 전처리
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("en"))
corpus <- tm_map(corpus, stripWhitespace)

# Document-Term Matrix 생성
dtm <- DocumentTermMatrix(corpus)

# 빈 문서(모든 값이 0인 행) 제거
non_empty_docs <- rowSums(as.matrix(dtm)) > 0
dtm <- dtm[non_empty_docs, ]
df <- df[non_empty_docs, ]  # df에서도 동일한 행 제거

# 희소한 단어 제거 (문서 간 출현 비율 99% 이상 단어 제거)
dtm <- removeSparseTerms(dtm, 0.99)

# 추가로 빈 행 여부 확인
non_empty_docs <- rowSums(as.matrix(dtm)) > 0
dtm <- dtm[non_empty_docs, ]
df <- df[non_empty_docs, ]

# 최종 확인
if (any(rowSums(as.matrix(dtm)) == 0)) {
    stop("DTM contains empty rows even after preprocessing. Please check the data.")
}

# CTM 모델 훈련
num_topics <- 10  # 주제 개수 설정
ctm_model <- CTM(as.DocumentTermMatrix(dtm), k = num_topics, control = list(seed = 1234))

# 각 문서에 대한 토픽 비율 추출 (theta)
topic_distributions <- as.data.frame(posterior(ctm_model)$topics)

# 문서 수가 일치하지 않으면 topic_distributions을 df 크기에 맞추기
if (nrow(df) > nrow(topic_distributions)) {
    extra_rows <- nrow(df) - nrow(topic_distributions)
    topic_distributions <- rbind(topic_distributions, matrix(NA, nrow = extra_rows, ncol = ncol(topic_distributions)))
}

# 엔트로피 계산 함수 (Depth 계산)
calculate_entropy <- function(topic_proportions) {
    -sum(topic_proportions * log2(topic_proportions + 1e-10))  # 엔트로피 계산, 작은 값 추가
}

# 각 문서에 대해 엔트로피(Depth) 계산
df$Depth <- apply(topic_distributions, 1, calculate_entropy)

# 전체 평균 토픽 비율 계산
global_topic_proportions <- colMeans(topic_distributions, na.rm = TRUE)

# KL 발산 계산 함수 (Breadth 계산)
calculate_kl_divergence <- function(review_topic_proportions, global_topic_proportions) {
    # 0이 발생하지 않도록 작은 값 추가
    review_topic_proportions <- review_topic_proportions + 1e-10
    global_topic_proportions <- global_topic_proportions + 1e-10
    
    # KL 발산 계산
    kl_divergence <- sum(review_topic_proportions * log2(review_topic_proportions / global_topic_proportions))
    
    # NaN 또는 Inf 값이 발생할 경우 0으로 처리
    if (is.nan(kl_divergence) | is.infinite(kl_divergence)) {
        return(NA)  # NaN이나 Inf일 경우 NA 반환
    } else {
        return(kl_divergence)
    }
}

# 각 문서에 대해 KL 발산(Breadth) 계산
df$Breadth <- apply(topic_distributions, 1, function(x) calculate_kl_divergence(x, global_topic_proportions))

# 결과를 CSV로 저장
write.csv(df, "/Users/hyunwoo/Desktop/PADA/PADA_LAB/calculated/sampled_hotel_1000_calculated_ctm.csv", row.names = FALSE)

# 완료 메시지 출력
cat("Analysis complete: Results saved to /Users/hyunwoo/Desktop/PADA/PADA_LAB/calculated/sampled_hotel_1000_calculated_ctm.csv\n")