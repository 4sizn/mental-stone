# Mental Stone — Flutter 모노레포 + Supabase 인증 (설계/스펙)

- 날짜: 2026-06-21
- 상태: 승인됨 (브레인스토밍 완료)
- 디자인 출처: claude.ai/design 프로젝트 "Flutter 디자인 시스템 구성" (`f3a28eef-...`), `Design System.dc.html` / `DESIGN.md`
- Supabase 프로젝트: `qnrhgqnietcwrryvqfga` (`https://qnrhgqnietcwrryvqfga.supabase.co`)

## 1. 목표

"Mental Stone" — 감정 기록/저널링 모바일 앱 (iOS + Android, 프로덕션 지향).
디자인 시스템 **"Ethereal Clarity"**(glassmorphism, Hanken Grotesk, Material 3 light)를 기반으로,
Melos 모노레포 위에서 **이메일 회원가입/로그인**이 실제 동작하는 v1을 만든다.

### 범위
- **v1 (이번 구현)**: 모노레포 + 디자인시스템/코어 패키지 + 화면 이식 + Supabase 스키마/RLS/트리거 + 이메일 인증(확인 OFF) 전 구간 동작 + 검증.
- **v2 (분리)**: 카카오 네이티브 로그인 (`kakao_flutter_sdk_user` → `signInWithIdToken(provider: kakao)`). auth repository는 provider 확장이 쉬운 구조로 미리 설계하고, 로그인 화면에 카카오 버튼 자리를 주석으로 남긴다.
- **범위 밖(문서만)**: 앱 서명/프로비저닝, fastlane, CI/CD, 실제 스토어 제출.

## 2. 아키텍처 (Melos 모노레포)

`mental-stone/`를 **독립 git 저장소**로 초기화한다(부모 `lotus`는 무관한 워크스페이스라 분리). Turborepo는 JS/TS 전용이라 Dart 패키지에 부적합하므로 사용하지 않는다.

```
mental-stone/
├─ melos.yaml                  # 워크스페이스 + bootstrap/analyze/test/format 스크립트
├─ pubspec.yaml                # 워크스페이스 루트 (dev_dependencies: melos)
├─ analysis_options.yaml       # 공유 lint
├─ apps/
│  └─ mobile/                  # Flutter 앱 (iOS + Android), --org com.rsupport
│     ├─ lib/
│     │  ├─ main.dart          # ProviderScope → bootstrap → App
│     │  ├─ bootstrap.dart     # Supabase.initialize(env)
│     │  ├─ env.dart           # --dart-define-from-file 매핑 (String.fromEnvironment)
│     │  ├─ app.dart           # MaterialApp.router + AppTheme
│     │  ├─ router/            # go_router + auth redirect guard
│     │  └─ features/
│     │     ├─ auth/           # sign_in, sign_up 화면 + controller
│     │     ├─ home/ records/ record/ analysis/ synthesis/ diary/ profile/
│     │     └─ shell/          # MainShell (bottom nav host)
│     ├─ android/  ios/        # flutter create 생성, 네이티브 설정
│     ├─ test/                 # 위젯/단위 테스트
│     ├─ integration_test/     # 실제 Supabase 대상 인증 e2e
│     ├─ env.example.json
│     └─ pubspec.yaml
├─ packages/
│  ├─ mental_stone_ui/         # 디자인시스템 패키지
│  │  ├─ lib/
│  │  │  ├─ mental_stone_ui.dart        # barrel export
│  │  │  ├─ theme/ (app_colors, app_typography, app_dimens, app_theme)
│  │  │  └─ widgets/ (glass_card, glass_button, glass_input, emotion_chip,
│  │  │              glow_bar, emotion_stone, mesh_background,
│  │  │              mental_stone_app_bar, glass_bottom_nav)
│  │  └─ assets/fonts/ (HankenGrotesk-*.ttf, OFL)
│  └─ mental_stone_core/       # 데이터/도메인 패키지
│     └─ lib/
│        ├─ mental_stone_core.dart      # barrel export
│        ├─ supabase/ (supabase_providers.dart)
│        ├─ auth/ (auth_repository.dart, auth_controller.dart, auth_state.dart)
│        ├─ profile/ (profile.dart, profile_repository.dart)
│        └─ journal/ (journal_entry.dart, journal_repository.dart)
└─ supabase/                   # 마이그레이션 보관 (MCP apply_migration 미러)
    └─ migrations/
```

- 앱은 `mental_stone_ui`, `mental_stone_core`를 **path 의존성**으로 사용.
- 상태관리: **Riverpod**, 라우팅: **go_router**.

## 3. 디자인 시스템 이식

디자인 프로젝트의 `flutter/lib/theme/*` + `widgets/*`(9개)를 `mental_stone_ui`로 이식하고
패키지 import 경로에 맞게 조정한다. 7개 화면(`home/diary/record/emotion_analysis/emotion_synthesis/records/main_shell`)은 앱 `features/`로 이식한다.

- 토큰: `DESIGN.md`의 색/타이포/spacing/radius를 그대로 따른다(이미 Dart로 구현됨).
- 폰트: **Hanken Grotesk** (OFL) 400/500/600/700 `.ttf`를 `mental_stone_ui/assets/fonts/`에 번들, 앱 pubspec에서 패키지 폰트 참조.
- 위계: Material elevation 대신 **backdrop blur + tonal stacking** 유지.
- `NetworkImage` 자리(아바타/스톤 아트)는 placeholder 유지 + TODO 표기.

## 4. Supabase 백엔드 (마이그레이션)

### 테이블
- **`public.profiles`**: `id uuid PK references auth.users on delete cascade`, `email text`, `display_name text`, `avatar_url text`, `created_at timestamptz default now()`, `updated_at timestamptz default now()`.
- **`public.journal_entries`**: `id uuid PK default gen_random_uuid()`, `user_id uuid references auth.users on delete cascade`, `mood text`, `body text`, `created_at timestamptz default now()`.

### RLS (모두 활성화)
- `profiles`: `select`/`update`는 `auth.uid() = id`. insert는 트리거 경유.
- `journal_entries`: `select`/`insert`/`update`/`delete`는 `auth.uid() = user_id`.

### 함수/트리거
- `handle_new_user()` — `auth.users` AFTER INSERT → `profiles` 행 생성. `display_name`/`avatar_url`은 `raw_user_meta_data`(이메일은 `name`/`full_name`, v2 카카오는 `nickname`/`profile_image`)에서 추출, 없으면 이메일 local-part.
- `handle_email_autoconfirm()` — `auth.users` BEFORE INSERT → `email_confirmed_at := now()` (이메일 확인 OFF 동등). 프로덕션 전환 시 이 트리거를 drop하고 대시보드에서 Confirm email을 관리하도록 SETUP.md에 명시.
- `set_updated_at()` — `profiles` BEFORE UPDATE → `updated_at := now()`.

## 5. 인증 흐름 (v1: 이메일)

`mental_stone_core`:
- `supabaseClientProvider` → `Supabase.instance.client`.
- `AuthRepository`:
  - `signUpWithEmail({email, password, displayName})` → `auth.signUp(data: {name})`; 확인 OFF이므로 즉시 세션. 세션이 null이면 `signInWithPassword` 폴백.
  - `signInWithEmail({email, password})`.
  - `signOut()`.
  - (v2 자리) `signInWithKakao()` — 미구현, 인터페이스만 주석으로 예약.
- `authStateProvider` = `StreamProvider`(`auth.onAuthStateChange`), 현재 세션/유저 노출.
- `AuthController`(`AsyncNotifier`) — 폼 제출, 로딩/에러 상태, `AuthException` 메시지 한글 매핑.

세션 영속화는 `supabase_flutter`가 자동 처리.

## 6. 라우팅 & 가드 (go_router)

- `routerProvider`가 `authStateProvider`를 `refreshListenable`로 구독.
- `redirect`: 세션 없음 + 보호 라우트 → `/sign-in`. 세션 있음 + `/sign-in|/sign-up` → `/home`.
- 라우트: `/sign-in`, `/sign-up`, ShellRoute(`/home`, `/records`, `/profile`) + push 라우트(`/record`, `/analysis`, `/synthesis`, `/diary/:id`).

## 7. 설정 & 시크릿

- `--dart-define-from-file=apps/mobile/env.json` (gitignore) + `env.example.json` 커밋.
- 키: `SUPABASE_URL`, `SUPABASE_ANON_KEY`(publishable), `KAKAO_NATIVE_APP_KEY`(v2 placeholder).
- `env.dart`는 `String.fromEnvironment`로 컴파일타임 주입.
- Bundle/Application ID: **`com.rsupport.mentalstone`**.
- 네이티브 카카오 설정(Android custom scheme, iOS URL scheme/LSApplicationQueriesSchemes)은 v2 placeholder + SETUP.md 가이드.

## 8. 테스트 & 검증

- `melos run analyze` → 0 issue.
- 단위: `AuthRepository`(mock client), 한글 에러 매핑.
- 위젯: sign-in 화면 렌더 + 유효성.
- 통합(`integration_test` 또는 헤드리스 Dart): 실제 Supabase 대상 `signUp`→세션 발급→`profiles` 행 생성 확인→`signOut`. (이메일 확인 OFF 동작 증명)
- 컴파일 증명: `flutter build apk --debug`(Android) + `flutter build ios --no-codesign`(iOS).
- `mcp__supabase__get_advisors`로 보안/성능 권고 점검(RLS 등).

## 9. 산출물

1. 독립 git 저장소 + `.gitignore` + `README.md`.
2. Melos 워크스페이스(루트 pubspec/melos.yaml/analysis_options).
3. `mental_stone_ui` 패키지(테마+위젯+폰트).
4. `mental_stone_core` 패키지(supabase/auth/profile/journal + providers + 테스트).
5. `apps/mobile`(라우터+인증화면+이식 화면+네이티브 설정).
6. Supabase 마이그레이션 적용(테이블/RLS/트리거).
7. `SETUP.md`(환경키, 이메일확인/auto-confirm 설명, v2 카카오 가이드, 스토어 배포 가이드).

## 10. 외부 의존성 (사용자 준비)

- (v2) 카카오 개발자 앱: REST API 키, Client Secret, Native 앱 키, OIDC 활성화, 키 해시.
- (추후) Apple Developer / Google Play 계정·서명.
- Supabase "Confirm email"은 v1에서 DB auto-confirm 트리거로 우회하므로 대시보드 조작 불필요.

## 11. 비목표 (YAGNI)

- 다크 모드(라이트만), 푸시 알림, 실제 AI 감정분석 백엔드, 소셜 공유 — 모두 후속.
