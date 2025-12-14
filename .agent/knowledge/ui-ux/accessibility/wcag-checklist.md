# WCAG アクセシビリティチェックリスト

**最終更新**: 2025-12-15
**対象**: WCAG 2.1 レベルAA準拠

---

## 使用方法

このチェックリストは、UI/UX設計・実装時に使用してください：

- **設計フェーズ**: ワイヤーフレーム・デザイン作成時
- **実装フェーズ**: コード実装後
- **テストフェーズ**: リリース前の検証
- **監査**: 定期的なアクセシビリティ監査時

---

## WCAG 2.1 準拠レベル

- **レベルA**: 最低限の要件（必須）
- **レベルAA**: 推奨される要件（目標）
- **レベルAAA**: 最高レベル（理想）

**このチェックリストはレベルAA準拠を目標とします。**

---

## 1. 知覚可能（Perceivable）

### 1.1 テキストによる代替（レベルA）

#### 必須チェック項目

- [ ] **画像のalt属性**: 全ての意味のある画像にalt属性があるか
- [ ] **装飾画像**: 装飾のみの画像は`alt=""`か`role="presentation"`か
- [ ] **アイコンのラベル**: アイコンボタンにaria-labelがあるか
- [ ] **フォーム要素のラベル**: 全ての入力要素に`<label>`が関連付けられているか
- [ ] **リンクテキスト**: リンクのテキストが目的を説明しているか（「こちら」ではなく）

#### Good / Bad Example

##### Good ✅
```html
<!-- 画像のalt属性 -->
<img src="product.jpg" alt="赤いTシャツ（Mサイズ）">

<!-- 装飾画像 -->
<img src="decoration.svg" alt="" role="presentation">

<!-- アイコンボタン -->
<button aria-label="メニューを開く">
  <svg>...</svg>
</button>

<!-- フォームラベル -->
<label for="email">メールアドレス</label>
<input type="email" id="email" name="email">

<!-- 意味のあるリンクテキスト -->
<a href="/pricing">料金プランを見る</a>
```

##### Bad ❌
```html
<!-- alt属性なし（NG!） -->
<img src="product.jpg">

<!-- 意味のない alt（NG!） -->
<img src="chart.png" alt="image123">

<!-- ラベルなしアイコン（NG!） -->
<button>
  <svg>...</svg>  <!-- 何のボタンか不明 -->
</button>

<!-- ラベルなしフォーム（NG!） -->
<input type="text" placeholder="名前を入力">  <!-- labelなし -->

<!-- 意味のないリンクテキスト（NG!） -->
<a href="/pricing">こちら</a>
<a href="/pricing">詳細</a>
```

---

### 1.2 時間依存メディア（レベルAA）

#### 必須チェック項目

- [ ] **動画の字幕**: 動画に字幕（キャプション）があるか
- [ ] **音声の文字起こし**: 音声コンテンツの文字起こしが提供されているか
- [ ] **音声解説**: 動画に音声解説（Audio Description）があるか

---

### 1.3 適応可能（レベルA）

#### 必須チェック項目

- [ ] **セマンティックHTML**: 適切なHTML要素を使用しているか
- [ ] **見出し構造**: `<h1>`〜`<h6>`が論理的な順序か
- [ ] **リスト**: リストに`<ul>`, `<ol>`, `<li>`を使用しているか
- [ ] **ランドマークロール**: `<header>`, `<nav>`, `<main>`, `<footer>`を使用しているか
- [ ] **フォーム構造**: `<fieldset>`, `<legend>`でグループ化されているか

#### Good / Bad Example

##### Good ✅
```html
<!-- セマンティックHTML -->
<header>
  <nav aria-label="メインナビゲーション">
    <ul>
      <li><a href="/">ホーム</a></li>
      <li><a href="/about">会社概要</a></li>
    </ul>
  </nav>
</header>

<main>
  <h1>製品一覧</h1>
  <section>
    <h2>カテゴリA</h2>
    <article>
      <h3>製品1</h3>
      <p>説明...</p>
    </article>
  </section>
</main>

<footer>
  <p>&copy; 2025 Company</p>
</footer>

<!-- フォームのグループ化 -->
<form>
  <fieldset>
    <legend>配送先住所</legend>
    <label for="zip">郵便番号</label>
    <input type="text" id="zip" name="zip">

    <label for="address">住所</label>
    <input type="text" id="address" name="address">
  </fieldset>
</form>
```

##### Bad ❌
```html
<!-- 非セマンティック（NG!） -->
<div class="header">
  <div class="nav">
    <div class="list">
      <div><a href="/">ホーム</a></div>  <!-- NG! -->
    </div>
  </div>
</div>

<div class="content">
  <div class="title">製品一覧</div>  <!-- NG! h1を使うべき -->
</div>

<!-- 見出しの順序が不適切（NG!） -->
<h1>製品一覧</h1>
<h3>カテゴリA</h3>  <!-- NG! h2を飛ばしている -->
```

---

### 1.4 識別可能（レベルAA）

#### 必須チェック項目

- [ ] **色のコントラスト**: テキストと背景のコントラスト比が4.5:1以上か（大きいテキストは3:1）
- [ ] **色だけで情報伝達しない**: 色以外の手段（アイコン、テキスト）も併用しているか
- [ ] **テキストのリサイズ**: 200%に拡大しても情報が失われないか
- [ ] **テキスト画像の回避**: テキストはCSSでスタイリングしているか（画像ではなく）
- [ ] **フォーカス表示**: キーボードフォーカスが視覚的に明確か

#### Good / Bad Example

##### Good ✅
```css
/* コントラスト比4.5:1以上 */
.text {
  color: #1a1a1a;       /* 濃いグレー */
  background: #ffffff;   /* 白 */
  /* コントラスト比: 16.8:1 ✅ */
}

/* フォーカス表示 */
button:focus {
  outline: 2px solid #0056b3;
  outline-offset: 2px;
}

/* エラー表示（色+アイコン） */
.error {
  color: #d32f2f;
  border-left: 4px solid #d32f2f;
}
.error::before {
  content: '⚠️';  /* アイコンも併用 */
}
```

##### Bad ❌
```css
/* コントラスト不足（NG!） */
.text {
  color: #aaaaaa;       /* 薄いグレー */
  background: #ffffff;  /* 白 */
  /* コントラスト比: 2.3:1 NG! */
}

/* フォーカス表示なし（NG!） */
button:focus {
  outline: none;  /* NG! */
}

/* 色のみで情報伝達（NG!） */
.success {
  color: green;  /* 緑のみで成功を表現 */
}
```

---

## 2. 操作可能（Operable）

### 2.1 キーボード操作可能（レベルA）

#### 必須チェック項目

- [ ] **キーボードアクセス**: 全ての機能がキーボードのみで操作可能か
- [ ] **フォーカストラップ**: モーダルダイアログでフォーカスが閉じ込められているか
- [ ] **Tabキー順序**: Tab移動の順序が論理的か
- [ ] **キーボードショートカット**: 重要な操作にショートカットがあるか

#### Good / Bad Example

##### Good ✅
```html
<!-- キーボード操作可能なカスタムボタン -->
<div
  role="button"
  tabindex="0"
  aria-label="お気に入りに追加"
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      addToFavorites();
    }
  }}
>
  ★
</div>

<!-- モーダルのフォーカストラップ -->
<div role="dialog" aria-labelledby="dialog-title" aria-modal="true">
  <h2 id="dialog-title">確認</h2>
  <p>削除してもよろしいですか？</p>
  <button>キャンセル</button>
  <button>削除</button>
</div>
```

##### Bad ❌
```html
<!-- キーボード操作不可（NG!） -->
<div onClick={handleClick}>
  クリック  <!-- divにはtabindexがなく、キーボードでアクセス不可 -->
</div>

<!-- onKeyDownなし（NG!） -->
<span onClick={handleClick}>送信</span>
```

---

### 2.2 十分な時間（レベルA）

#### 必須チェック項目

- [ ] **タイムアウト警告**: セッションタイムアウト前に警告を表示しているか
- [ ] **自動更新の制御**: 自動更新を停止・調整できるか
- [ ] **時間制限の延長**: 時間制限を延長できるか

---

### 2.3 発作の防止（レベルA）

#### 必須チェック項目

- [ ] **点滅の制限**: 1秒間に3回以上点滅するコンテンツがないか
- [ ] **フラッシュの回避**: 大きな領域での点滅を避けているか

---

### 2.4 ナビゲーション可能（レベルAA）

#### 必須チェック項目

- [ ] **スキップリンク**: メインコンテンツへのスキップリンクがあるか
- [ ] **ページタイトル**: 各ページに適切な`<title>`があるか
- [ ] **フォーカス順序**: フォーカス順序が論理的か
- [ ] **リンクの目的**: リンクのテキストまたはコンテキストから目的が分かるか
- [ ] **複数の経路**: サイト内の各ページに複数の到達方法があるか（ナビ、サイトマップ等）
- [ ] **見出しとラベル**: 見出しとラベルが内容を説明しているか

#### Good / Bad Example

##### Good ✅
```html
<!-- スキップリンク -->
<a href="#main-content" class="skip-link">メインコンテンツへスキップ</a>

<nav>...</nav>

<main id="main-content">
  <h1>ページタイトル</h1>
  ...
</main>

<!-- ページタイトル -->
<title>料金プラン - サービス名</title>

<!-- 明確なリンクテキスト -->
<a href="/pricing">料金プランを見る</a>
```

##### Bad ❌
```html
<!-- スキップリンクなし（NG!） -->

<!-- 不適切なページタイトル（NG!） -->
<title>ページ1</title>

<!-- 不明確なリンクテキスト（NG!） -->
<a href="/pricing">詳細</a>
```

---

## 3. 理解可能（Understandable）

### 3.1 読みやすい（レベルA）

#### 必須チェック項目

- [ ] **言語設定**: `<html lang="ja">`が設定されているか
- [ ] **部分的な言語変更**: 外国語部分に`lang`属性があるか
- [ ] **明確な言語**: 専門用語に説明があるか

#### Good / Bad Example

##### Good ✅
```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <title>サイト名</title>
</head>
<body>
  <p>これは日本語のテキストです。</p>
  <p lang="en">This is English text.</p>
</body>
</html>
```

##### Bad ❌
```html
<!DOCTYPE html>
<html>  <!-- lang属性なし（NG!） -->
<head>
  <title>サイト名</title>
</head>
<body>
  <p>これは日本語のテキストです。</p>
</body>
</html>
```

---

### 3.2 予測可能（レベルA）

#### 必須チェック項目

- [ ] **フォーカス時の変化**: フォーカスしただけでコンテキストが変化しないか
- [ ] **入力時の変化**: 入力しただけで予期しない変化が起こらないか
- [ ] **一貫したナビゲーション**: サイト全体で一貫したナビゲーションか
- [ ] **一貫した識別**: 同じ機能に同じラベルを使用しているか

#### Good / Bad Example

##### Good ✅
```html
<!-- フォーカスでコンテキストが変化しない -->
<select id="country" onChange={handleChange}>
  <option value="">国を選択</option>
  <option value="jp">日本</option>
  <option value="us">アメリカ</option>
</select>

<!-- 送信ボタンで明示的に変更 -->
<button type="submit">検索</button>
```

##### Bad ❌
```html
<!-- フォーカスで自動送信（NG!） -->
<select onChange={autoSubmit}>
  <option>選択肢1</option>
  <option>選択肢2</option>
</select>
```

---

### 3.3 入力支援（レベルAA）

#### 必須チェック項目

- [ ] **エラー識別**: エラーがテキストで説明されているか
- [ ] **ラベルまたは指示**: フォームに明確な指示があるか
- [ ] **エラー修正の提案**: エラー時に修正方法を提示しているか
- [ ] **エラー防止**: 重要な操作前に確認画面があるか
- [ ] **autocomplete属性**: 個人情報フィールドにautocomplete属性があるか

#### Good / Bad Example

##### Good ✅
```html
<!-- エラー識別 -->
<form>
  <label for="email">メールアドレス *</label>
  <input
    type="email"
    id="email"
    aria-describedby="email-error"
    aria-invalid="true"
  >
  <span id="email-error" role="alert">
    有効なメールアドレスを入力してください（例: user@example.com）
  </span>
</form>

<!-- autocomplete属性 -->
<input type="text" name="name" autocomplete="name">
<input type="email" name="email" autocomplete="email">
<input type="tel" name="tel" autocomplete="tel">

<!-- 重要な操作の確認 -->
<button onClick={() => {
  if (confirm('本当に削除しますか？')) {
    deleteItem();
  }
}}>
  削除
</button>
```

##### Bad ❌
```html
<!-- エラー識別なし（NG!） -->
<input type="email" style="border-color: red;">
<!-- 色だけでエラーを表現 -->

<!-- autocomplete属性なし（NG!） -->
<input type="text" name="name">
```

---

## 4. 堅牢性（Robust）

### 4.1 互換性（レベルA）

#### 必須チェック項目

- [ ] **妥当なHTML**: HTMLバリデーションエラーがないか
- [ ] **ARIA属性の適切な使用**: ARIA属性が正しく使用されているか
- [ ] **ステータスメッセージ**: 動的な更新が`role="status"`等で通知されているか

#### Good / Bad Example

##### Good ✅
```html
<!-- 妥当なHTML -->
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>ページタイトル</title>
</head>
<body>
  <main>
    <h1>見出し</h1>
  </main>
</body>
</html>

<!-- ステータスメッセージ -->
<div role="status" aria-live="polite">
  保存しました
</div>

<!-- ARIA属性の適切な使用 -->
<button aria-expanded="false" aria-controls="menu">
  メニュー
</button>
<ul id="menu" hidden>
  <li><a href="#">項目1</a></li>
</ul>
```

##### Bad ❌
```html
<!-- 妥当でないHTML（NG!） -->
<div>
  <p>段落1</div>  <!-- 閉じタグが間違っている -->
</p>

<!-- ARIA属性の誤用（NG!） -->
<div role="button">  <!-- buttonを使うべき -->
  クリック
</div>
```

---

## チェックリスト完了基準

### レベルA（必須）
- [ ] 1.1 テキストによる代替（5項目）
- [ ] 1.3 適応可能（5項目）
- [ ] 2.1 キーボード操作可能（4項目）
- [ ] 2.2 十分な時間（3項目）
- [ ] 2.3 発作の防止（2項目）
- [ ] 3.1 読みやすい（3項目）
- [ ] 3.2 予測可能（4項目）
- [ ] 4.1 互換性（3項目）

### レベルAA（推奨）
- [ ] 1.2 時間依存メディア（3項目）
- [ ] 1.4 識別可能（5項目）
- [ ] 2.4 ナビゲーション可能（6項目）
- [ ] 3.3 入力支援（5項目）

---

## 自動チェックツール

```bash
# axe DevTools（ブラウザ拡張）
# https://www.deque.com/axe/devtools/

# Pa11y（CLI）
pa11y https://example.com

# Lighthouse（Chrome DevTools）
lighthouse https://example.com --view

# axe-core（プログラマティック）
npm install @axe-core/cli
axe https://example.com
```

---

## 参考資料

- **WCAG 2.1**: https://www.w3.org/TR/WCAG21/
- **JIS X 8341-3:2016**: https://www.jisc.go.jp/
- **MDN Accessibility**: https://developer.mozilla.org/ja/docs/Web/Accessibility
- **A11y Project**: https://www.a11yproject.com/

---

**このチェックリストを使用して、誰もが使いやすいWebサイトを作成してください。**
