<img src="https://capsule-render.vercel.app/api?type=waving&color=BDBDC8&height=150&section=header" />

# PADA_LAB
<img src="https://github.com/user-attachments/assets/35685bcc-e06f-445e-b45d-428e643349c8" alt="제목을 입력해주세요" width="300" height="270">


## DATA Preprocessing git

### 희령 필규
- Sentiment: BERT모델을 통한 pre-train 모델 혹은 감정의 원주율 모델 사용 논의 후 결정😮‍💨
### 현우, 수진

<details>
<summary>
  Readability: FOG or FRE
</summary>
  사용된 수식 설명<br/>
   $\text{FOG Index} = 0.4 \times \left( \frac{\text{Total Words}}{\text{Total Sentences}} + 100 \times \frac{\text{Complex Words}}{\text{Total Words}} \right)$ <br/> <br/>
   $\text{FRE Score} = 206.835 - (1.015 \times \frac{\text{Total Words}}{\text{Total Sentences}}) - (84.6 \times \frac{\text{Total Syllables}}{\text{Total Words}})$
</details>

- Length (Review Text, Review title): 단어수

- Breadth : 토픽모델링 후 진행🧐

- Depth : 얼마나 한 주제에 집중하고 있는가😦

- Time lapsed : 리뷰 수집일 - 리뷰 게시일😖

- Deviation of star ratings : |리뷰의 평점 - 평균평점|😫
