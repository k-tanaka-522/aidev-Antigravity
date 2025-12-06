# インフラ構成書 (Infrastructure Configuration)

**作成者**: DevOps Agent
**レビュー**: Architect, Security
**バージョン**: 1.0

## 1. 環境概要
*   **開発環境**: [Docker Compose / Localhost]
*   **CI/CD**: [GitHub Actions / CircleCI]
*   **本番環境**: [AWS / Vercel / GCP]

## 2. コンテナ構成 (Containerization)
### 2.1 Frontend
*   Base Image: `node:18-alpine`
*   Exposed Port: 3000
*   Env Vars: `NEXT_PUBLIC_API_URL`

### 2.2 Backend
*   Base Image: `python:3.9-slim`
*   Exposed Port: 8000
*   Dependencies: `requirements.txt`

## 3. CI/CDパイプライン
### 3.1 Build Stage
*   Command: `npm run build`
*   Artifacts: `dist/`

### 3.2 Test Stage
*   Command: `npm run test`

### 3.3 Deploy Stage
*   Trigger: Push to `main`
*   Target: Production

## 4. 運用手順
*   **デプロイ手順**: `git push origin main`
*   **ロールバック手順**: ...
*   **ログ確認方法**: ...
