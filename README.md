# 뉴런연구소 학원 파트너 사이트

뉴런연구소의 학원 파트너용 Level-X 콘텐츠 소개 및 도입 문의를 받기 위한 정적 웹사이트입니다. 별도의 빌드 단계 없이 `index.html`과 `contents.html`을 브라우저에서 바로 렌더링하며, 샘플 PDF/이미지 자산과 Firebase Analytics, Google Apps Script 기반 문의 접수 로직을 함께 사용합니다.

배포 도메인은 `CNAME` 기준 `partner.newlearn-soft.com`입니다.

## 주요 기능

### 홈 페이지

`index.html`은 학원 파트너 프로그램의 랜딩 페이지입니다.

- 히어로 영역에서 Level-X 봉투 패키지 이미지를 보여주고 도입 문의 또는 콘텐츠 소개 페이지로 이동합니다.
- 뉴런연구소의 역할을 평가원/EBS 분석, 학원 진도 맞춤 운영, 출제·인쇄·발송 대행, 검수 후 배송 흐름으로 설명합니다.
- 프로그램 절차를 `도입 문의 -> 1:1 상담 -> 단원·난이도 선택 -> 제작·검수 후 배송` 4단계로 안내합니다.
- 하단 도입 문의 폼에서 담당자명, 연락처, 학원명, 관심 과목, 대단원, 세부 단원, 희망 Level, 문의 내용을 수집합니다.
- 과목 선택에 따라 대단원과 세부 단원 체크박스가 단계적으로 생성됩니다.
- 폼 제출 시 Google Apps Script URL로 JSON 데이터를 `POST` 전송합니다.
- 봇 제출 방지를 위해 숨겨진 honeypot 필드와 3초 미만 제출 차단 로직이 들어 있습니다.
- 카카오톡 채널 플로팅 버튼을 제공합니다.

### 콘텐츠 소개 페이지

`contents.html`은 Level-X 상품과 커리큘럼을 상세히 보여주는 페이지입니다.

- Level-X의 출제 원칙을 평가원 트렌드 분석, EBS 연계 분석, 월별 단원·Level 선택, 실전형 구성으로 설명합니다.
- Basic, Standard, Killer, Final 4개 라인업을 카드로 보여줍니다.
- 샘플 전체 ZIP 파일(`SAMPLE/Level-X-sample-all.zip`)을 다운로드할 수 있습니다.
- 각 콘텐츠 카드 클릭 시 PDF 미리보기 모달을 띄우고, 새 창에서 PDF를 열 수 있습니다.
- 수학 I, 수학 II, 확률과 통계, 미적분의 27개 단원을 아코디언 테이블로 제공합니다.
- 과목별 테이블은 모두 펼치기/접기를 지원합니다.
- Level-Basic, Level-Standard, Level-Killer, Level-Final별 추천 학생과 활용 가이드를 별도 섹션으로 설명합니다.
- 3월부터 10월까지 시즌1~시즌8 연간 운영 일정을 타임라인으로 안내합니다.
- 하단 CTA에서 홈 페이지의 도입 문의 폼으로 이동합니다.

### 공통 동작

- CSS는 각 HTML 내부에 포함되어 있어 외부 빌드 도구가 필요 없습니다.
- Pretendard 웹폰트를 CDN에서 불러옵니다.
- Firebase Analytics를 CDN ES module로 초기화합니다.
- CTA 클릭, 내비게이션 클릭, 스크롤 깊이, 섹션 조회, 섹션 체류 시간, PDF 미리보기, 샘플 다운로드, 문의 폼 이벤트를 추적합니다.
- `IntersectionObserver`를 사용해 스크롤 reveal 애니메이션과 섹션 체류 추적을 처리합니다.
- `prefers-reduced-motion` 환경에서는 애니메이션을 줄입니다.
- SEO를 위해 canonical, meta description, Open Graph, Twitter Card, JSON-LD, `robots.txt`, `sitemap.xml`을 포함합니다.

## 프로젝트 구조

```text
.
├── CNAME
├── README.md
├── index.html
├── contents.html
├── robots.txt
├── sitemap.xml
├── IMAGE/
│   ├── Cover.png
│   ├── basic.png
│   ├── standard.png
│   ├── killer.png
│   ├── final.png
│   └── newlearn_logo.svg
├── SAMPLE/
│   ├── BASIC.pdf
│   ├── BASIC_answer.pdf
│   ├── STANDARD.pdf
│   ├── STANDARD_answer.pdf
│   ├── KILLER.pdf
│   ├── KILLER_answer.pdf
│   ├── Level-F-math.pdf
│   ├── Level-F-math-answer.pdf
│   ├── Level-F-eng.pdf
│   ├── Level-F-eng-answer.pdf
│   └── Level-X-sample-all.zip
└── scripts/
    └── render_covers.swift
```

## 작동 방식

### 정적 페이지 렌더링

이 프로젝트는 프레임워크나 번들러 없이 HTML 파일 자체가 하나의 완성된 페이지입니다. HTML 내부에 메타 태그, CSS, SVG 아이콘, JavaScript가 함께 들어 있습니다. GitHub Pages, Netlify, Vercel 정적 배포, S3 정적 호스팅처럼 HTML 파일을 그대로 서빙하는 환경에서 동작합니다.

### 문의 폼 제출 흐름

1. 사용자가 `index.html#inquiry`의 폼을 작성합니다.
2. 과목 체크박스가 변경되면 `curriculum` 객체를 기준으로 대단원 목록이 동적으로 렌더링됩니다.
3. 대단원을 선택하면 선택된 과목/대단원 조합에 맞는 세부 단원 목록이 렌더링됩니다.
4. 제출 시 `FormData`를 객체로 변환하고 `_submitted_at`, `_page_url` 메타 정보를 추가합니다.
5. Google Apps Script 엔드포인트로 `text/plain;charset=utf-8` 형식의 JSON 문자열을 전송합니다.
6. 응답이 JSON의 `result/status: success` 또는 `OK`로 시작하면 성공 화면을 보여줍니다.
7. 실패하면 버튼을 복구하고 이메일 직접 문의 안내 토스트를 표시합니다.

### PDF 미리보기 흐름

1. `contents.html`의 `.pdf-preview-card` 요소는 `data-pdf`, `data-title` 속성을 갖습니다.
2. 사용자가 카드 클릭 또는 Enter/Space 키 입력을 하면 PDF 모달이 열립니다.
3. iframe의 `src`가 `SAMPLE/*.pdf#page=1&zoom=80` 형태로 설정됩니다.
4. 모달 안의 "새 창으로 열기" 링크도 같은 PDF를 가리킵니다.
5. 닫기 버튼, 배경 클릭, Escape 키로 모달을 닫습니다.

### 분석 이벤트

두 페이지 모두 Firebase Analytics를 사용합니다. 주요 이벤트는 다음과 같습니다.

- `partner_page_view`
- `cta_click`
- `nav_click`
- `scroll_depth`
- `section_view`
- `section_dwell`
- `content_interest`
- `sample_download`
- `pdf_preview_open`
- `pdf_open_external`
- `curriculum_expand`
- `curriculum_collapse`
- `curriculum_toggle_all`
- `inquiry_form_start`
- `inquiry_option_select`
- `inquiry_submit_attempt`
- `inquiry_submit_success`
- `inquiry_submit_error`

## 로컬 실행

단순 확인은 HTML 파일을 브라우저에서 직접 열어도 됩니다.

```bash
open index.html
```

PDF iframe, canonical 경로, 일부 브라우저 보안 정책까지 실제 배포와 비슷하게 확인하려면 로컬 서버로 여는 편이 좋습니다.

```bash
python3 -m http.server 8080
```

그다음 브라우저에서 아래 주소를 엽니다.

```text
http://localhost:8080/
http://localhost:8080/contents.html
```

## 운영 및 수정 가이드

### 메인 문구 수정

- 홈 페이지 문구는 `index.html`의 각 섹션에서 수정합니다.
- 콘텐츠 소개 문구와 상품 라인업 설명은 `contents.html`에서 수정합니다.

### 샘플 PDF 교체

- 문제지/답지 PDF는 `SAMPLE/`에 위치합니다.
- 콘텐츠 카드의 PDF 경로는 `contents.html`의 `data-pdf` 속성에서 관리합니다.
- 전체 다운로드 ZIP은 `SAMPLE/Level-X-sample-all.zip` 파일을 교체하면 됩니다.

### 표지 이미지 교체

- 홈 히어로 이미지는 `IMAGE/Cover.png`입니다.
- 상세 라인업 이미지는 `IMAGE/basic.png`, `IMAGE/standard.png`, `IMAGE/killer.png`, `IMAGE/final.png`입니다.
- Open Graph/Twitter 공유 이미지는 현재 `IMAGE/Cover.png`를 사용합니다.

### 단원 구성 수정

단원 데이터는 두 곳에 있습니다.

- 홈 문의 폼의 동적 선택 데이터: `index.html` 하단의 `curriculum` 객체
- 콘텐츠 페이지의 공개 단원표: `contents.html`의 아코디언 테이블

운영 중 단원명이 바뀌면 두 위치를 함께 맞춰야 합니다.

### 문의 접수 엔드포인트 변경

`index.html` 하단 스크립트의 `SCRIPT_URL` 값을 변경하면 됩니다.

```js
const SCRIPT_URL = 'https://script.google.com/macros/s/.../exec';
```

폼은 JSON 문자열을 `text/plain;charset=utf-8`로 전송하므로, Apps Script 쪽에서도 같은 형식을 기준으로 파싱해야 합니다.

### Firebase 프로젝트 변경

`index.html`과 `contents.html` 상단 module script의 `firebaseConfig` 값을 함께 변경해야 합니다. 두 페이지 모두 동일한 프로젝트 설정을 사용합니다.

## 표지 렌더링 스크립트

`scripts/render_covers.swift`는 AppKit을 사용해 커버 이미지를 JPEG로 생성하는 macOS용 Swift 스크립트입니다.

- `drawMockExamCover()`는 봉투 모의고사 커버를 그립니다.
- `drawWeeklyCover()`는 주간 학습지 커버를 그립니다.
- 실행하면 현재 작업 디렉터리 기준 `assets/covers/rendered/` 아래에 JPEG를 생성합니다.

실행 예시는 다음과 같습니다.

```bash
swift scripts/render_covers.swift
```

현재 웹페이지에서 직접 참조하는 이미지는 `IMAGE/` 아래 PNG 파일들이며, Swift 스크립트 출력물은 별도 제작용 자산입니다.

## 배포 체크리스트

- `CNAME`이 실제 배포 도메인과 일치하는지 확인합니다.
- `sitemap.xml`의 URL과 `lastmod`를 최신 상태로 갱신합니다.
- `robots.txt`의 Sitemap URL이 올바른지 확인합니다.
- `index.html`, `contents.html`의 canonical URL과 OG URL이 배포 도메인과 일치하는지 확인합니다.
- 샘플 PDF와 ZIP 파일이 정상 다운로드되는지 확인합니다.
- 문의 폼이 Apps Script로 정상 접수되는지 확인합니다.
- Firebase Analytics 이벤트가 수집되는지 확인합니다.

## 외부 의존성

- Pretendard 웹폰트 CDN: `cdn.jsdelivr.net`
- Firebase JavaScript SDK CDN: `www.gstatic.com`
- Firebase Analytics 프로젝트: `partner-web-e78fe`
- Google Apps Script 문의 접수 API
- KakaoTalk 채널 링크: `https://pf.kakao.com/_TrZxjX`

## 참고 사항

Firebase Analytics 설정값은 클라이언트에 노출되는 구조가 일반적이지만, Google Apps Script 엔드포인트는 공개 URL이므로 스팸 방지와 저장소 권한 설정을 Apps Script 쪽에서 함께 관리해야 합니다. 현재 프론트엔드에는 honeypot과 빠른 제출 차단이 들어 있지만, 최종 검증은 서버 측에서 처리하는 것이 안전합니다.
