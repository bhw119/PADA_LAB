<img src="https://capsule-render.vercel.app/api?type=waving&color=BDBDC8&height=150&section=header" />

# PADA_LAB
<img src="https://github.com/user-attachments/assets/35685bcc-e06f-445e-b45d-428e643349c8" alt="제목을 입력해주세요" width="300" height="270">

## DATA Preprocessing git

### 희령 필규
- **Sentiment**: BERT 모델을 통한 pre-train 모델 혹은 감정의 원주율 모델 사용 논의 후 결정 😮‍💨
- ***감정의 원주율 모델*** : 단어사전의 단어들을 임베딩한 후 리뷰 데이터 또한 임베딩. 각 임베딩값의 코사인 유사도와 문장 전체의 코사인 유사도를 모두 고려하여 감정의 좌표를 구하게 됨
- ***BERT*** : 현재 LoRA(Low- Rank Adaptatio)을 통해 파인튜닝을 진행하여 모델을 구성해보았으나 기본 BERT pre-trained 모델보다 성능이 좋지 못함. 그냥 원본 데이터의 샘플을 통해 구하는 것이 더 좋을 듯함 

### 현우, 수진
<summary>
  Dev_of_star_rating: 별점의 분포(극단성)
</summary>
<summary>
  length: 리뷰와 리뷰 제목의 단어 수
</summary>
<summary>
  time_lapsed: 리뷰가 작성된 후 얼마나 지났는가
</summary>



<details>

  
<summary>
  Readability: FOG or FRE
</summary>
  사용된 수식 설명:<br/>
  $\text{FOG Index} = 0.4 \times \left( \frac{\text{Total Words}}{\text{Total Sentences}} + 100 \times \frac{\text{Complex Words}}{\text{Total Words}} \right)$<br/>
  $\text{FRE Score} = 206.835 - (1.015 \times \frac{\text{Total Words}}{\text{Total Sentences}}) - (84.6 \times \frac{\text{Total Syllables}}{\text{Total Words}})$
</details>

<details>
<summary>
CTM vs LDA vs LSA
</summary>
  
| **모델**            | **핵심 개념**                        | **가정**                       | **장점**                           | **단점**                        |
|----------------------|-------------------------------------|--------------------------------|----------------------------------|---------------------------------|
| **LSA**             | SVD를 사용한 행렬 분해              | 단어의 잠재 의미 공간 존재      | 빠르고 구현이 간단                | 확률 모델이 아니며 해석이 어렵다   |
| **LDA**             | 확률적 토픽 모델                    | 문서-토픽, 토픽-단어 독립       | 해석이 직관적, 확률적 모델링      | 계산 비용이 높고 하이퍼파라미터 설정 필요 |
| **CTM**             | LDA + 토픽 간 상관관계 모델링       | 토픽 간 상관관계 존재           | 더 정교한 토픽 구조 학습 가능     | 계산 비용이 높고 구현이 복잡      |

</details>

- **Length (Review Text, Review title)**: 단어수

<details>
<summary>
**Breadth**: 토픽모델링 후 진행🧐
</summary>
<img width="1178" alt="image (7)" src="https://github.com/user-attachments/assets/cad0747a-9977-44ec-b45e-925d0c20f5b8" />

  
</details>

<details>
<summary>
  Depth: 얼마나 한 주제에 집중하고 있는가😦
</summary>

리뷰 데이터 분석 및 **ContentDepth** 계산:

1. **텍스트 전처리**  
   리뷰 데이터를 **용어-문서 행렬(Term-Document Matrix)**로 변환하기 위해 CountVectorizer를 사용합니다. 이 과정에서는 텍스트에서 가장 많이 등장하는 단어를 특징 단어로 선택하여, 각 단어와 문서 간의 관계를 나타내는 행렬을 생성합니다.  
   - CountVectorizer는 텍스트에서 자주 등장하는 단어들을 벡터 형태로 변환하여 모델에 적용할 수 있게 합니다.
   - 이 때, 최대 1000개의 특징 단어만 사용합니다.

2. **LDA 모델 학습**  
   LDA(잠재 디리클레 할당) 모델을 사용하여 텍스트 데이터에서 주제를 추출합니다. 주제는 문서 내 단어들의 패턴을 기반으로 자동으로 학습되며, 이 모델은 각 문서가 어떤 주제에 얼마나 속하는지를 추정합니다.  
   - **n_components=10**: 10개의 주제를 추출합니다.
   - **max_iter=20**: 20번의 반복을 통해 모델을 학습합니다.
   - **learning_method='online'**: 온라인 학습 방법을 사용하여 점진적으로 데이터를 처리합니다.

3. **각 문장의 주제 비율 계산**  
   각 문장이 어떤 주제에 얼마나 속하는지를 계산하기 위해 LDA 모델을 사용합니다. 각 문장은 여러 주제에 대해 비율을 가지며, 이 비율을 기반으로 문서의 주제 분포를 이해할 수 있습니다.  
   - 각 문장은 주제 비율을 계산하여, 해당 문장이 어떤 주제에 속하는지 파악할 수 있습니다.

4. **문장 단위 주제 비율을 리뷰 단위로 집계**  
   리뷰는 여러 문장으로 이루어져 있으므로, 각 문장의 주제 비율을 계산한 후, 이들의 평균을 구하여 리뷰 전체에 대한 주제 비율을 구합니다.  
   - 여러 문장의 주제 비율을 평균하여 리뷰 전체의 주제 비율을 구합니다.

5. **Shannon 엔트로피 계산**  
   주제 비율에 대한 Shannon 엔트로피를 계산하여 주제 분포의 불확실성 정도를 측정합니다. 엔트로피 값이 높을수록 주제 분포가 다양하고 불확실한 분포를 의미합니다.  
   - Shannon 엔트로피는 주제 분포의 혼잡도를 나타내며, 주제가 고르게 분포될수록 엔트로피 값이 커집니다.

6. **ContentDepth 계산**  
   ContentDepth는 리뷰의 주제 비율을 평균하여 엔트로피 값을 계산한 후, 이를 리뷰 내 문장의 수로 정규화한 값입니다. 이 값은 리뷰가 얼마나 다양한 주제를 다루고 있는지를 나타내며, 값이 클수록 다양한 주제를 포함한 리뷰임을 의미합니다.  
   - ContentDepth는 주제의 다양성과 리뷰의 문장 수에 따라 결정됩니다.

7. **각 리뷰에 대해 ContentDepth 적용**  
   각 리뷰에 대해 ContentDepth와 그 음수 값인 ContentBreadth를 계산하여 DataFrame에 추가합니다.  
   - ContentBreadth는 ContentDepth의 음수로 정의됩니다. 이 값은 리뷰의 주제 다양성을 반영하며, 내용의 깊이를 표현하는 지표로 사용됩니다.

8. **결과 출력**  
   최종적으로 각 리뷰에 대해 ContentDepth와 ContentBreadth 값을 출력하여, 리뷰가 얼마나 다양한 주제를 포함하고 있는지, 또는 얼마나 집중된 내용을 다루고 있는지를 파악할 수 있습니다.

</details>

- **Time lapsed**: 리뷰 수집일 - 리뷰 게시일😖
- **Deviation of star ratings**: |리뷰의 평점 - 평균평점|😫

# 사용방법
Jupyter notebook에서 Preprocessing_code 내의 preprocessing_merged.ipynb를 실행한 후 R studio에서 ctm_depth_and_length.r을 실행하여 모든 feature들을 추가할 수 있음.
