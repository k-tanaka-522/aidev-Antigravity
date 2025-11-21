# aidev-antigravity (Self-Improving 9-Agent Team Core)

**PMを司令塔とする9名の自律エージェントチーム（自己進化型）** の構成定義リポジトリです。
あなたのプロジェクトに「最強のチーム」をインストールします。

## クイックスタート (Quick Start)

### パターンA: 新規プロジェクトとして開始
このリポジトリをテンプレートとして、新しいプロジェクトを開始する場合の手順です。

```bash
# 1. リポジトリをクローン
git clone https://github.com/k-tanaka-522/aidev-antigravity.git my-project
cd my-project

# 2. 新規プロジェクト初期化スクリプトを実行（重要！）
# Windows
scripts\init-new-project.bat

# Mac/Linux
./scripts/init-new-project.sh

# 3. エディタで開く
code .
```

**重要**: `init-new-project` を実行することで、Git履歴がリセットされ、クリーンな状態で開発をスタートできます。

---

### パターンB: 既存プロジェクトに追加
すでに進行中のプロジェクトに、Antigravityチームを招聘する場合の手順です。

```bash
cd your-existing-project

# 1. 一時的に clone
git clone https://github.com/k-tanaka-522/aidev-antigravity.git .antigravity-temp

# 2. 設定フォルダ (.agent_config) をコピー
# Mac/Linux
cp -r .antigravity-temp/.agent_config .
cp .antigravity-temp/PROJECT_STRUCTURE.md .

# Windows (PowerShell)
Copy-Item -Path ".\.antigravity-temp\.agent_config" -Destination "." -Recurse
Copy-Item -Path ".\.antigravity-temp\PROJECT_STRUCTURE.md" -Destination "."

# 3. 一時ディレクトリを削除
# Mac/Linux
rm -rf .antigravity-temp

# Windows (PowerShell)
Remove-Item -Path ".\.antigravity-temp" -Recurse -Force
```

---

## 使い方 (Usage)

### チーム始動
プロジェクトを開き、エージェント（PM）に話しかけてください。
`.agent_config` が読み込まれ、9名のエージェントが待機状態になります。

### 自己進化 (Kaizen)
プロジェクト終了後、CKOによって改善された設定をマスターリポジトリに還流させます。

1.  **改善された設定をマスターにコピー**
    ```bash
    cp -r .agent_config ../aidev-antigravity/
    ```
2.  **マスターリポジトリでPush**
    ```bash
    cd ../aidev-antigravity
    git add .
    git commit -m "Kaizen: Update from Project X"
    git push
    ```
