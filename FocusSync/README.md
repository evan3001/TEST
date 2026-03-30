# FocusSync - 크로스 디바이스 집중 & 공부 트래커

## 실행 방법

### 방법 1: xcodegen 사용 (추천)

```bash
# 1. xcodegen 설치 (한 번만)
brew install xcodegen

# 2. 프로젝트 생성 & 열기
cd FocusSync
xcodegen generate
open FocusSync.xcodeproj
```

Xcode에서 시뮬레이터 선택 후 `Cmd + R`로 실행.

### 방법 2: Xcode에서 직접 생성

1. Xcode 열기 → `File` → `New` → `Project`
2. `Multiplatform` → `App` 선택 → 이름: `FocusSync`
3. 생성된 `ContentView.swift` 삭제
4. `FocusSyncApp/` 폴더 안의 모든 `.swift` 파일을 프로젝트에 드래그
5. `Cmd + R`로 실행
