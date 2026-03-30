# FocusSync - Cross-Device Focus & Study Tracker

## 아키텍처 개요

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   iPhone    │    │    iPad     │    │   MacBook   │
│  (SwiftUI)  │    │  (SwiftUI)  │    │  (SwiftUI)  │
├─────────────┤    ├─────────────┤    ├─────────────┤
│ScreenTime   │    │ScreenTime   │    │ NSWorkspace │
│FamilyControl│    │FamilyControl│    │  Monitor    │
├─────────────┤    ├─────────────┤    ├─────────────┤
│  ViewModel  │    │  ViewModel  │    │  ViewModel  │
├─────────────┤    ├─────────────┤    ├─────────────┤
│ CloudSync   │◄──►│ CloudSync   │◄──►│ CloudSync   │
│  Manager    │    │  Manager    │    │  Manager    │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
       └──────────┬───────┴──────────────────┘
                  │
         ┌────────▼────────┐
         │  iCloud Private │
         │   Database      │
         │  (CloudKit)     │
         └─────────────────┘
```

## 핵심 동작 흐름

### 1. 집중 모드 시작 (iPhone에서 시작하는 경우)
1. 유저가 iPhone에서 "시작" 버튼 탭
2. `FocusSession` 생성 → CloudKit에 저장 (`isActive = true`)
3. iPhone: Screen Time API로 앱 차단 즉시 활성화
4. CloudKit → Silent Push Notification → iPad, MacBook
5. iPad: 알림 수신 → active session fetch → Screen Time 차단 활성화
6. MacBook: 알림 수신 → active session fetch → NSWorkspace 모니터링 시작

### 2. 앱 허용 목록
- 유저가 "앱 설정" 탭에서 토글로 허용 앱 선택
- 집중 모드 시작 시 허용 앱 목록이 세션에 포함
- Screen Time API의 shield에서 해당 앱 제외

### 3. 세션 종료
1. 어느 기기에서든 "종료" 버튼 탭
2. 세션 `isActive = false`, `endTime` 기록 → CloudKit 저장
3. 모든 기기에 push → 차단 해제 + 히스토리 갱신

## 프로젝트 구조

```
FocusSync/
├── Shared/
│   ├── Models/
│   │   ├── FocusSession.swift      # 세션 데이터 + CloudKit 변환
│   │   ├── AllowedApp.swift         # 허용 앱 모델 + 프리셋
│   │   └── DeviceInfo.swift         # 기기 정보
│   ├── Services/
│   │   ├── CloudSyncManager.swift   # CloudKit 동기화 + Push 구독
│   │   ├── ScreenTimeManager.swift  # 앱 차단 (iOS: ScreenTime, macOS: fallback)
│   │   └── SessionHistoryStore.swift # 히스토리 + 통계
│   ├── ViewModels/
│   │   └── FocusViewModel.swift     # 메인 뷰모델
│   ├── Views/
│   │   ├── MainTabView.swift        # 탭 구조
│   │   ├── FocusTimerView.swift     # 타이머 화면
│   │   ├── HistoryView.swift        # 기록 화면
│   │   ├── AllowedAppsView.swift    # 앱 설정 화면
│   │   ├── DevicesView.swift        # 기기 목록 화면
│   │   └── Components/
│   │       └── FocusShieldView.swift # 전체화면 차단 오버레이
│   └── FocusSyncApp.swift           # 앱 진입점 + AppDelegate
├── iOS/
│   └── Info.plist
├── macOS/
│   └── Info.plist
├── FocusSync.entitlements
└── Package.swift
```

## 사용된 Apple 프레임워크

| 프레임워크 | 용도 | 플랫폼 |
|-----------|------|--------|
| CloudKit | 실시간 크로스 디바이스 동기화 | iOS, iPadOS, macOS |
| FamilyControls | Screen Time 인증 | iOS, iPadOS |
| ManagedSettings | 앱 차단/해제 | iOS, iPadOS |
| DeviceActivity | 사용 모니터링 | iOS, iPadOS |
| SwiftUI | UI | 전체 |

## Xcode 설정 필요 사항

1. **Apple Developer Account** 필요 (유료)
2. **Capabilities 추가:**
   - iCloud → CloudKit 활성화
   - Push Notifications 활성화
   - Family Controls 활성화 (iOS target)
   - Background Modes → Remote notifications
3. **CloudKit Dashboard에서** `FocusSession` 레코드 타입 생성
4. **Provisioning Profile**에 Family Controls entitlement 포함
