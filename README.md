# Mental Stone

감정 기록/저널링 모바일 앱 (iOS + Android). **"Ethereal Clarity"** glassmorphism 디자인 시스템 +
Supabase 백엔드(이메일 인증) 기반의 Flutter 모노레포.

## 모노레포 구조 (Melos + Dart pub workspaces)

```
mental-stone/
├─ apps/mobile/              # Flutter 앱 (iOS + Android)
├─ packages/
│  ├─ mental_stone_ui/       # 디자인 시스템: 테마 토큰 + glass 위젯
│  └─ mental_stone_core/     # Supabase 클라이언트 + auth + profile/journal 리포지토리 (Riverpod)
├─ supabase/migrations/      # DB 마이그레이션 (profiles, journal_entries, RLS, 트리거)
└─ docs/                     # 스펙 문서
```

- **상태관리/라우팅**: Riverpod + go_router (세션 기반 라우트 가드)
- **백엔드**: Supabase (Postgres + Auth + RLS)
- **디자인**: Material 3 light, Hanken Grotesk, backdrop-blur 기반 glassmorphism

## 빠른 시작

```bash
# 1) Melos 설치 (최초 1회)
dart pub global activate melos

# 2) 의존성 부트스트랩 (워크스페이스 전체)
flutter pub get

# 3) 환경 파일 준비
cp apps/mobile/env.example.json apps/mobile/env.json
#   → env.json 에 SUPABASE_URL / SUPABASE_KEY 입력

# 4) 실행
cd apps/mobile
flutter run --dart-define-from-file=env.json
```

## 기능 (v1)

- 이메일 회원가입 / 로그인 / 로그아웃 (세션 영속화)
- 세션 기반 라우팅 (미인증 → 로그인 화면)
- 프로필 자동 생성 (가입 시 트리거) + 프로필 화면
- 감정 기록 작성(저장) / 홈 최근 기록 목록 (Supabase + RLS)
- 7개 디자인 화면 (Home / Records / Record / Analysis / Synthesis / Diary / Profile)

## 로드맵

- **v2**: 카카오 네이티브 로그인 (`SETUP.md` 참고)
- 이후: 실제 AI 감정분석, 다크 모드, 푸시 알림, 스토어 배포 (`SETUP.md`)

자세한 설정·배포·v2 가이드는 [`SETUP.md`](./SETUP.md), 설계는
[`docs/superpowers/specs/`](./docs/superpowers/specs/) 참고.
