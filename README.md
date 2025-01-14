<img  src="https://capsule-render.vercel.app/api?type=waving&color=BDBDC8&height=150&section=header"  />

  

# PADA_LAB

<img  src="https://github.com/user-attachments/assets/35685bcc-e06f-445e-b45d-428e643349c8"  alt="제목을 입력해주세요"  width="300"  height="270">

  

## DATA Preprocessing git

  

### 희령 필규

-  **Sentiment**: BERT 모델을 통한 pre-train 모델 혹은 감정의 원주율 모델 사용 논의 후 결정 😮‍💨

-  ***감정의 원주율 모델*** : 단어사전의 단어들을 임베딩한 후 리뷰 데이터 또한 임베딩. 각 임베딩값의 코사인 유사도와 문장 전체의 코사인 유사도를 모두 고려하여 감정의 좌표를 구하게 됨

-  ***BERT*** : 현재 LoRA(Low- Rank Adaptatio)을 통해 파인튜닝을 진행하여 모델을 구성해보았으나 기본 BERT pre-trained 모델보다 성능이 좋지 못함. 그냥 원본 데이터의 샘플을 통해 구하는 것이 더 좋을 듯함

  

### 현우, 수진

<summary>

**Dev_of_star_rating**: 별점의 분포(극단성)

</summary>

<summary>

**length**: 리뷰와 리뷰 제목의 단어 수

</summary>

<summary>

**time_lapsed**: 리뷰가 작성된 후 얼마나 지났는가

</summary>

  
  
  

<details>

  

<summary>

**Readability**: FOG or FRE

</summary>

사용된 수식 설명:<br/>

$\text{FOG Index} = 0.4 \times \left( \frac{\text{Total Words}}{\text{Total Sentences}} + 100 \times \frac{\text{Complex Words}}{\text{Total Words}} \right)$<br/>

$\text{FRE Score} = 206.835 - (1.015 \times \frac{\text{Total Words}}{\text{Total Sentences}}) - (84.6 \times \frac{\text{Total Syllables}}{\text{Total Words}})$

</details>

**Length** (Review Text, Review title): 단어수

  
  

**Depth**: 얼마나 한 주제에 집중하고 있는가😦

<details>

<summary>

Depth는 각 리뷰에 대해 NMF(Non-Negative Matrix Factorization) 기반의 주제 모델링을 통해 계산됩니다.

</summary>

  
  

</details>

  

<details>

  
  

<summary>

**Breadth**: 얼마나 다양한 주제를 다루고 있는가😦

</summary>

<img  width="1178"  alt="image (7)"  src="https://github.com/user-attachments/assets/cad0747a-9977-44ec-b45e-925d0c20f5b8"  />

  

Breadth는 각 리뷰의 주제 기여도를 기반으로 KL 발산을 계산하여 평가됩니다.

  

</details>

# 사용방법

final 폴더 내의 depth_and_breadth.ipynb 파일을 실행하면 depth와 breadth가 계산됩니다.

  
  
  

-  **Time lapsed**: 리뷰 수집일 - 리뷰 게시일😖

-  **Deviation of star ratings**: |리뷰의 평점 - 평균평점|😫