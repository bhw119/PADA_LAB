#!/bin/bash

# 원격 저장소 URL 설정
REPO_URL="https://github.com/bhw119/PADA_LAB.git"

# 임시 폴더에서 클론 수행
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# 클론 시도
echo "Cloning repository to temporary directory..."
git clone --filter=blob:none "$REPO_URL" temp_repo

cd temp_repo

# 잘못된 파일 확인 및 삭제
echo "Finding and removing invalid files..."
INVALID_FILES=$(git ls-tree -r --name-only HEAD | grep -E '\?')

for FILE in $INVALID_FILES; do
    git rm --cached "$FILE"
    echo "Removed invalid file: $FILE"
done

# 변경 사항 커밋 및 푸시
git commit -m "Remove files with invalid characters"
git push origin main

# 클론 완료
echo "Cloning cleaned repository to target directory..."
cd ..
git clone "$REPO_URL" cleaned_repo

echo "Repository is ready in the 'cleaned_repo' folder."
