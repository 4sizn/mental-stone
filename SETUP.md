# Mental Stone — Setup & Operations

## 1. 사전 요구사항

- Flutter `>=3.22` (개발/검증은 3.41.9 / Dart 3.11.5에서 수행)
- Xcode (iOS), Android Studio + SDK (Android)
- Melos: `dart pub global activate melos`

## 2. 의존성 부트스트랩

Dart pub workspaces를 사용하므로 루트에서 한 번만 받으면 모든 패키지가 연결됩니다.

```bash
flutter pub get          # 루트에서 (apps/mobile + packages/* 전부 해석)
```

Melos 스크립트:

```bash
melos run analyze        # 모든 패키지 정적 분석
melos run test           # test/ 가 있는 모든 패키지 테스트
melos run format         # 포맷
```

## 3. 환경 변수 (`--dart-define-from-file`)

`apps/mobile/env.json` (gitignore됨)을 만들고 실행 시 주입합니다.

```jsonc
{
  "SUPABASE_URL": "https://<project-ref>.supabase.co",
  "SUPABASE_KEY": "sb_publishable_...",   // publishable 키 권장 (legacy anon 키도 가능)
  "KAKAO_NATIVE_APP_KEY": ""               // v2
}
```

```bash
cd apps/mobile
flutter run   --dart-define-from-file=env.json
flutter test  --dart-define-from-file=env.json     # 통합 테스트 시
flutter build apk     --dart-define-from-file=env.json
flutter build ios     --dart-define-from-file=env.json --no-codesign
```

현재 개발용 `env.json`에는 이 프로젝트의 Supabase(`qnrhgqnietcwrryvqfga`) publishable 키가 들어 있습니다.

## 4. Supabase 백엔드

마이그레이션은 `supabase/migrations/`에 있으며, 원격 프로젝트에 이미 적용되어 있습니다.

| 객체 | 설명 |
|---|---|
| `public.profiles` | 유저 1:1 프로필. RLS: 본인 row만 select/update |
| `public.journal_entries` | 감정/일기 기록. RLS: 본인 데이터만 CRUD |
| `handle_new_user()` 트리거 | `auth.users` insert → `profiles` 자동 생성 (메타데이터 `name`/`nickname`, avatar 추출) |
| `set_updated_at()` 트리거 | `profiles.updated_at` 자동 갱신 |
| `dev_auto_confirm_email()` 트리거 | **DEV 전용** — 이메일 확인 OFF 동등 |

Supabase CLI로 로컬/신규 프로젝트에 재현하려면:

```bash
supabase link --project-ref <ref>
supabase db push        # supabase/migrations/* 적용
```

### 이메일 확인 (Confirm email)

v1은 빠른 검증을 위해 **확인 OFF**입니다. 이는 `dev_auto_confirm_email` 트리거가
`auth.users` insert 시 `email_confirmed_at`을 채워, 가입 즉시 세션을 받도록 구현돼 있습니다
(MCP로는 Auth config 토글이 불가해 DB 레벨로 처리).

**프로덕션 전환 시:**
1. 트리거 제거:
   ```sql
   drop trigger if exists dev_auto_confirm_email_trigger on auth.users;
   drop function if exists public.dev_auto_confirm_email();
   ```
2. Supabase Dashboard → Authentication → Sign In / Providers → Email →
   **Confirm email** 정책을 원하는 대로 설정 (확인 메일 사용 시 SMTP 구성 권장).
3. 확인 메일을 쓰면 앱의 가입 후 흐름에 "메일함 확인" 안내를 추가하세요
   (`AuthRepository.signUpWithEmail`은 세션이 없으면 자동 로그인을 시도하므로, 확인 ON에서는
   미확인 사용자에 대해 `email not confirmed` 메시지가 노출됩니다).

## 5. v2 — 카카오 네이티브 로그인

검증된 경로: 카카오 네이티브 SDK 로그인 → OIDC `idToken` → `supabase.auth.signInWithIdToken(provider: kakao)`.
(`signInWithIdToken`은 Kakao를 공식 지원 — Supabase 문서 확인 완료.)

### 5.1 카카오 개발자 포털
1. https://developers.kakao.com 에서 앱 생성.
2. **REST API 키** = Supabase의 Kakao `Client ID`.
3. **카카오 로그인 활성화** + **OpenID Connect 활성화(State ON)**, scope에 `openid` + `profile_nickname`/`profile_image`/`account_email` 추가.
4. **Client Secret** 발급/활성화 = Supabase의 Kakao `Client Secret`.
5. 플랫폼 등록: Android(패키지명 `com.rsupport.mental_stone` + 키 해시), iOS(번들 ID).
6. **네이티브 앱 키** → `env.json`의 `KAKAO_NATIVE_APP_KEY`.

### 5.2 Supabase
Dashboard → Authentication → Providers → **Kakao** 활성화, Client ID/Secret 입력.
(이메일 미수집 앱이면 "Allow users without an email" ON.)

### 5.3 Flutter
```yaml
# apps/mobile/pubspec.yaml
dependencies:
  kakao_flutter_sdk_user: ^1.9.0
```
`main()`에서 `KakaoSdk.init(nativeAppKey: Env.kakaoNativeAppKey);`
그리고 `mental_stone_core`의 `AuthRepository.signInWithKakao()` 주석을 해제 (구조는 이미 예약됨).
로그인 화면(`sign_in_screen.dart`)의 `// v2: Kakao` 자리에 GlassButton 추가.

### 5.4 네이티브 설정
- **Android** `android/app/src/main/AndroidManifest.xml`: 카카오 로그인 리다이렉트용
  `kakao{NATIVE_APP_KEY}://oauth` 스킴 + 키 해시 등록.
- **iOS** `ios/Runner/Info.plist`: `CFBundleURLTypes`에 `kakao{NATIVE_APP_KEY}`,
  `LSApplicationQueriesSchemes`에 `kakaokompassauth`, `kakaolink`.

## 6. 스토어 배포 (범위 밖 — 가이드)

- **Application/Bundle ID**: `com.rsupport.mental_stone` (flutter create 기본값).
- **Android 서명**: `android/key.properties` + keystore (gitignore됨), `build.gradle` 서명 구성, `flutter build appbundle --release`.
- **iOS 서명**: Apple Developer 계정 + Xcode signing(Team/Provisioning), `flutter build ipa --release`.
- **CI/CD**: fastlane(`match`/`supply`/`deliver`) + GitHub Actions 권장.
- 위 단계는 Apple Developer / Google Play 계정과 자격증명이 필요합니다.

## 7. 검증 기록 (v1)

- `flutter analyze`: 에러/경고 0 (info 린트만).
- 단위/위젯 테스트: ui 4 + core 6 + app 2 = **12 통과**.
- e2e (실제 Supabase): 가입→즉시 세션, 프로필 트리거 생성, journal RLS insert/select 본인만,
  미인증 select 차단 — 모두 확인 후 테스트 데이터 정리.
- 보안 advisor: 0건 (트리거 함수 RPC 노출 차단 + search_path 고정 완료).
