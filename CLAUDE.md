# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 프로젝트 목표 (Project Goal)

이 저장소는 **유준영(Junyoung Yu)의 이력서(CV)**를 Jekyll + GitHub Pages로 운영하는 개인 이력서 웹사이트입니다.

**핵심 목적:**
- `index.md`를 지속적으로 업데이트하여 최신 경력, 프로젝트, 학력 정보를 반영
- 각 업데이트를 Git 커밋으로 버전 관리 (예: `v1.0`, `v1.1` 식의 태그 활용 권장)
- 라이브 사이트: https://swssmjy86.github.io/

**버전 관리 방침:**
- 현재 버전은 `version.txt`에 저장 (`v{major}.{minor}` 형식)
- `index.md` 수정 후 `scripts/version-push.ps1`이 자동 실행되어 minor 버전 증가, `Last Updated` 날짜 갱신, Git 태그 생성, GitHub push를 일괄 처리
- **major 버전 업** (이직, 학위 취득 등 중요 변경): `version.txt`를 직접 수정 후 스크립트 실행
- Claude Stop 훅(`.claude/hooks/auto-push.ps1`)이 대기 중으로 `index.md` 변경이 감지되면 자동으로 버전 푸시

---

## 기술 스택 (Tech Stack)

- **Static Site Generator:** Jekyll (GitHub Pages 기본값 사용, 별도 Gemfile 없음)
- **콘텐츠:** `index.md` (kramdown Markdown)
- **스타일:** `_sass/_solo.scss` (주요 테마), `css/main.scss` (진입점)
- **레이아웃:** `_layouts/default.html`

---

## 로컬 개발 (Local Development)

```bash
# 최초 1회: Ruby + Jekyll + Bundler 설치 후
bundle install

# 로컬 서버 실행
bundle exec jekyll serve
# → http://localhost:4000 에서 확인
```

의존성 없이 `index.md`만 편집하고 GitHub에 push하면 자동 배포됨.

---

## 콘텐츠 구조 (Content Structure)

모든 이력서 콘텐츠는 `index.md` 단일 파일에 집중되어 있음:

| 섹션 | 내용 |
|------|------|
| Contact | 연락처, 이메일, SNS |
| Education | 학력 (학위, 학교, 기간) |
| Work Experience | 경력 (직책, 회사, 기간, 담당 업무) |
| Notable Projects | 주요 프로젝트 (Innovation / Research / Development 분류) |
| Personal | 가치관, 취미, 가족 사항 |

스타일·레이아웃 변경 시에는 `_sass/_solo.scss`와 `_layouts/default.html`을 수정.

---

## 버전 푸시 방법 (Version Push)

`index.md`를 수정하면 Claude Stop 훅이 자동으로 버전 관리 및 push를 처리합니다.  
수동으로 실행할 때는:

```powershell
# 변경 내용 설명과 함께 실행
./scripts/version-push.ps1 "Work Experience 업데이트 - Cellumed 직책 추가"

# 설명 생략 시 'CV 업데이트' 기본값 사용
./scripts/version-push.ps1
```

스크립트가 자동으로 수행하는 작업:
1. `version.txt` minor 버전 증가 (예: `v1.2` → `v1.3`)
2. `index.md` 하단 `Last Updated` 날짜 오늘로 갱신
3. `git commit -m "[v1.3] 설명"` 생성
4. `git tag -a v1.3` 태그 생성
5. `git push origin master && git push origin v1.3`

---

## 배포 (Deployment)

`master` 브랜치에 push하면 GitHub Pages가 자동으로 Jekyll 빌드 및 배포.  
별도 CI/CD 파이프라인 없음.

---

## 이력서 웹사이트 플랫폼 추천 (Platform Recommendations)

현재 Jekyll + GitHub Pages 스택은 가볍고 무료지만, 이력서 **버전 관리 + 시각적 전문성**을 높이려면 아래 대안 검토를 권장:

| 플랫폼 | 장점 | 단점 |
|--------|------|------|
| **현재 (Jekyll/GitHub Pages)** | 무료, Git 버전 관리 완벽, 커스텀 가능 | 디자인 작업 필요, 비개발자에게 진입장벽 |
| **Read.cv** | 이력서 특화 UI, 깔끔한 디자인, 버전 히스토리 내장 | 커스터마이징 제한 |
| **Notion (공개 페이지)** | 편집 쉬움, 실시간 업데이트, 링크 공유 용이 | 브랜딩 제한, 노션 URL |
| **LinkedIn + PDF 이력서 병행** | 채용 시장 표준, 검색 노출 | 개인 사이트 없음 |
| **Astro + Vercel** | 최신 프레임워크, 성능 최적화, 쉬운 배포 | 마이그레이션 작업 필요 |

**추천:** 현재 GitHub Pages 구조를 유지하면서 Git 태그로 버전 스냅샷을 관리하는 방식이 개발자 이력서로는 가장 적합. 필요 시 `v-YYYY-MM` 형식의 태그를 활용.
