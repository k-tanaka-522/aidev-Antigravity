# フォーム設計パターン

**最終更新**: 2025-12-15
**対象**: Webフォーム設計・実装

---

## 使用方法

このドキュメントは、フォーム設計・実装時に参照してください：

- **設計フェーズ**: フォーム構造の決定
- **実装フェーズ**: コーディング時の参考
- **アクセシビリティ確認**: WCAG 2.1準拠チェック
- **UXレビュー**: ユーザビリティ検証

---

## 1. 基本フォーム構造

### ✅ Good Practice

**Good**: セマンティックHTML + 適切なラベル
```html
<form action="/api/users" method="post" novalidate>
  <div class="form-group">
    <label for="email">
      メールアドレス <span class="required">*</span>
    </label>
    <input
      type="email"
      id="email"
      name="email"
      autocomplete="email"
      required
      aria-required="true"
      aria-describedby="email-help email-error"
    />
    <small id="email-help" class="form-text">
      ログインに使用するメールアドレスを入力してください
    </small>
    <span id="email-error" class="error" role="alert" aria-live="polite">
      <!-- エラーメッセージをここに表示 -->
    </span>
  </div>

  <div class="form-group">
    <label for="password">
      パスワード <span class="required">*</span>
    </label>
    <input
      type="password"
      id="password"
      name="password"
      autocomplete="new-password"
      required
      aria-required="true"
      aria-describedby="password-help password-error"
      minlength="8"
    />
    <small id="password-help" class="form-text">
      8文字以上の英数字を含むパスワード
    </small>
    <span id="password-error" class="error" role="alert" aria-live="polite">
      <!-- エラーメッセージをここに表示 -->
    </span>
  </div>

  <button type="submit" class="btn btn-primary">
    登録
  </button>
</form>
```

**Bad**:
```html
<!-- NG: ラベルなし、アクセシビリティ考慮なし -->
<form>
  <input type="text" placeholder="メールアドレス" />
  <input type="text" placeholder="パスワード" />
  <div onclick="submitForm()">送信</div>
</form>
```

**Why Bad**:
- placeholderはラベルの代わりにならない
- type="text"でパスワード（セキュリティリスク）
- divをボタン代わり（キーボード操作不可、スクリーンリーダー非対応）

---

## 2. バリデーション

### リアルタイムバリデーション

**Good**: blur時に検証、明確なエラー表示
```javascript
// HTML
<input
  type="email"
  id="email"
  aria-describedby="email-error"
  aria-invalid="false"
/>
<span id="email-error" role="alert"></span>

// JavaScript
const emailInput = document.getElementById('email');
const emailError = document.getElementById('email-error');

emailInput.addEventListener('blur', (e) => {
  const value = e.target.value;

  if (!value) {
    showError(emailInput, emailError, 'メールアドレスを入力してください');
  } else if (!isValidEmail(value)) {
    showError(emailInput, emailError, '正しいメールアドレス形式で入力してください');
  } else {
    clearError(emailInput, emailError);
  }
});

function showError(input, errorElement, message) {
  input.setAttribute('aria-invalid', 'true');
  input.classList.add('is-invalid');
  errorElement.textContent = message;
}

function clearError(input, errorElement) {
  input.setAttribute('aria-invalid', 'false');
  input.classList.remove('is-invalid');
  errorElement.textContent = '';
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
```

**Bad**:
```javascript
// NG: input時に即座に検証（ユーザーが入力中にエラー表示）
emailInput.addEventListener('input', (e) => {
  if (!isValidEmail(e.target.value)) {
    alert('メールアドレスが不正です');  // NG: alertは使わない
  }
});
```

---

### サーバーサイドエラー表示

**Good**: フィールドごとにエラー表示
```javascript
// サーバーレスポンス
{
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "email",
        "message": "このメールアドレスは既に使用されています"
      },
      {
        "field": "password",
        "message": "パスワードは8文字以上である必要があります"
      }
    ]
  }
}

// エラー表示処理
function displayServerErrors(errors) {
  errors.forEach(error => {
    const input = document.getElementById(error.field);
    const errorElement = document.getElementById(`${error.field}-error`);
    showError(input, errorElement, error.message);
  });

  // 最初のエラーフィールドにフォーカス
  const firstErrorField = document.querySelector('[aria-invalid="true"]');
  if (firstErrorField) {
    firstErrorField.focus();
  }
}
```

---

## 3. フォーム送信状態

### ローディング状態

**Good**: 明確なフィードバック + 二重送信防止
```html
<form id="registration-form">
  <!-- フォームフィールド -->

  <button type="submit" id="submit-btn" class="btn btn-primary">
    <span class="btn-text">登録</span>
    <span class="spinner" hidden aria-hidden="true">
      <!-- スピナーアイコン -->
    </span>
  </button>

  <div id="form-status" role="status" aria-live="polite" aria-atomic="true">
    <!-- ステータスメッセージ -->
  </div>
</form>

<script>
const form = document.getElementById('registration-form');
const submitBtn = document.getElementById('submit-btn');
const btnText = submitBtn.querySelector('.btn-text');
const spinner = submitBtn.querySelector('.spinner');
const statusDiv = document.getElementById('form-status');

form.addEventListener('submit', async (e) => {
  e.preventDefault();

  // ローディング状態に変更
  submitBtn.disabled = true;
  btnText.textContent = '送信中...';
  spinner.hidden = false;
  statusDiv.textContent = 'フォームを送信しています...';

  try {
    const response = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(getFormData())
    });

    if (response.ok) {
      statusDiv.textContent = '登録が完了しました';
      // 成功処理
    } else {
      const errorData = await response.json();
      displayServerErrors(errorData.error.details);
      statusDiv.textContent = '登録に失敗しました。エラーを確認してください。';
    }
  } catch (error) {
    statusDiv.textContent = 'ネットワークエラーが発生しました。';
  } finally {
    // ローディング状態を解除
    submitBtn.disabled = false;
    btnText.textContent = '登録';
    spinner.hidden = true;
  }
});
</script>
```

**Bad**:
```javascript
// NG: ボタンを無効化しない（二重送信リスク）
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  await fetch('/api/users', { /* ... */ });
  // ボタンが有効なまま → 連打可能
});
```

---

## 4. 複数ステップフォーム

### プログレスインジケーター付きウィザード

**Good**: ステップ表示 + 進捗確認
```html
<div class="form-wizard">
  <!-- プログレスバー -->
  <ol class="progress-steps" role="tablist">
    <li role="presentation">
      <button
        role="tab"
        aria-selected="true"
        aria-controls="step1-panel"
        id="step1-tab"
        class="active"
      >
        1. 基本情報
      </button>
    </li>
    <li role="presentation">
      <button
        role="tab"
        aria-selected="false"
        aria-controls="step2-panel"
        id="step2-tab"
        disabled
      >
        2. アカウント設定
      </button>
    </li>
    <li role="presentation">
      <button
        role="tab"
        aria-selected="false"
        aria-controls="step3-panel"
        id="step3-tab"
        disabled
      >
        3. 確認
      </button>
    </li>
  </ol>

  <!-- ステップ1 -->
  <div
    id="step1-panel"
    role="tabpanel"
    aria-labelledby="step1-tab"
    class="step active"
  >
    <h2>基本情報</h2>
    <div class="form-group">
      <label for="name">氏名 *</label>
      <input type="text" id="name" required />
    </div>
    <button type="button" onclick="goToStep(2)">次へ</button>
  </div>

  <!-- ステップ2 -->
  <div
    id="step2-panel"
    role="tabpanel"
    aria-labelledby="step2-tab"
    class="step"
    hidden
  >
    <h2>アカウント設定</h2>
    <div class="form-group">
      <label for="email">メールアドレス *</label>
      <input type="email" id="email" required />
    </div>
    <button type="button" onclick="goToStep(1)">戻る</button>
    <button type="button" onclick="goToStep(3)">次へ</button>
  </div>

  <!-- ステップ3 -->
  <div
    id="step3-panel"
    role="tabpanel"
    aria-labelledby="step3-tab"
    class="step"
    hidden
  >
    <h2>確認</h2>
    <dl>
      <dt>氏名</dt>
      <dd id="confirm-name"></dd>
      <dt>メールアドレス</dt>
      <dd id="confirm-email"></dd>
    </dl>
    <button type="button" onclick="goToStep(2)">戻る</button>
    <button type="submit">登録</button>
  </div>
</div>

<script>
function goToStep(stepNumber) {
  // 現在のステップをバリデーション
  const currentStep = document.querySelector('.step.active');
  if (!validateStep(currentStep)) {
    return;
  }

  // ステップを切り替え
  document.querySelectorAll('.step').forEach((step, index) => {
    if (index + 1 === stepNumber) {
      step.classList.add('active');
      step.hidden = false;
      document.getElementById(`step${stepNumber}-tab`).setAttribute('aria-selected', 'true');
    } else {
      step.classList.remove('active');
      step.hidden = true;
      document.getElementById(`step${index + 1}-tab`).setAttribute('aria-selected', 'false');
    }
  });

  // フォーカスを新しいステップに移動
  document.querySelector('.step.active h2').focus();
}

function validateStep(step) {
  const inputs = step.querySelectorAll('input[required]');
  let isValid = true;

  inputs.forEach(input => {
    if (!input.value) {
      showError(input, input.nextElementSibling, '必須項目です');
      isValid = false;
    }
  });

  return isValid;
}
</script>
```

---

## 5. インラインエディット

### テーブル内編集

**Good**: 明確な編集モード切り替え
```html
<table>
  <thead>
    <tr>
      <th>名前</th>
      <th>メールアドレス</th>
      <th>操作</th>
    </tr>
  </thead>
  <tbody>
    <tr data-user-id="123" data-edit-mode="false">
      <td>
        <span class="view-mode">山田太郎</span>
        <input class="edit-mode" type="text" value="山田太郎" hidden />
      </td>
      <td>
        <span class="view-mode">yamada@example.com</span>
        <input class="edit-mode" type="email" value="yamada@example.com" hidden />
      </td>
      <td>
        <button class="btn-edit view-mode" onclick="enterEditMode(this)">
          編集
        </button>
        <button class="btn-save edit-mode" onclick="saveRow(this)" hidden>
          保存
        </button>
        <button class="btn-cancel edit-mode" onclick="cancelEdit(this)" hidden>
          キャンセル
        </button>
      </td>
    </tr>
  </tbody>
</table>

<script>
function enterEditMode(btn) {
  const row = btn.closest('tr');
  row.dataset.editMode = 'true';

  // 表示モードを非表示、編集モードを表示
  row.querySelectorAll('.view-mode').forEach(el => el.hidden = true);
  row.querySelectorAll('.edit-mode').forEach(el => el.hidden = false);

  // 最初の入力フィールドにフォーカス
  row.querySelector('.edit-mode input').focus();
}

async function saveRow(btn) {
  const row = btn.closest('tr');
  const userId = row.dataset.userId;
  const inputs = row.querySelectorAll('.edit-mode input');

  const data = {
    name: inputs[0].value,
    email: inputs[1].value
  };

  try {
    const response = await fetch(`/api/users/${userId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    if (response.ok) {
      // 表示モードを更新
      row.querySelectorAll('.view-mode').forEach((el, index) => {
        if (el.tagName === 'SPAN') {
          el.textContent = inputs[index].value;
        }
      });

      exitEditMode(row);
    }
  } catch (error) {
    alert('保存に失敗しました');
  }
}

function cancelEdit(btn) {
  const row = btn.closest('tr');
  exitEditMode(row);
}

function exitEditMode(row) {
  row.dataset.editMode = 'false';
  row.querySelectorAll('.view-mode').forEach(el => el.hidden = false);
  row.querySelectorAll('.edit-mode').forEach(el => el.hidden = true);
}
</script>
```

---

## 6. オートコンプリート

### 検索候補表示

**Good**: ARIA属性でアクセシビリティ確保
```html
<div class="autocomplete-wrapper">
  <label for="search">ユーザー検索</label>
  <input
    type="text"
    id="search"
    role="combobox"
    aria-expanded="false"
    aria-autocomplete="list"
    aria-controls="search-results"
    aria-activedescendant=""
  />
  <ul
    id="search-results"
    role="listbox"
    hidden
  >
    <!-- 候補をここに表示 -->
  </ul>
</div>

<script>
const searchInput = document.getElementById('search');
const resultsList = document.getElementById('search-results');
let currentFocus = -1;

searchInput.addEventListener('input', async (e) => {
  const query = e.target.value;

  if (query.length < 2) {
    hideResults();
    return;
  }

  const results = await fetchSearchResults(query);
  displayResults(results);
});

function displayResults(results) {
  resultsList.innerHTML = '';

  results.forEach((result, index) => {
    const li = document.createElement('li');
    li.role = 'option';
    li.id = `result-${index}`;
    li.textContent = result.name;
    li.onclick = () => selectResult(result);
    resultsList.appendChild(li);
  });

  resultsList.hidden = false;
  searchInput.setAttribute('aria-expanded', 'true');
}

function hideResults() {
  resultsList.hidden = true;
  searchInput.setAttribute('aria-expanded', 'false');
  currentFocus = -1;
}

// キーボードナビゲーション
searchInput.addEventListener('keydown', (e) => {
  const items = resultsList.querySelectorAll('li');

  if (e.key === 'ArrowDown') {
    currentFocus++;
    if (currentFocus >= items.length) currentFocus = 0;
    setActive(items);
  } else if (e.key === 'ArrowUp') {
    currentFocus--;
    if (currentFocus < 0) currentFocus = items.length - 1;
    setActive(items);
  } else if (e.key === 'Enter') {
    e.preventDefault();
    if (currentFocus > -1) {
      items[currentFocus].click();
    }
  } else if (e.key === 'Escape') {
    hideResults();
  }
});

function setActive(items) {
  items.forEach((item, index) => {
    if (index === currentFocus) {
      item.classList.add('active');
      searchInput.setAttribute('aria-activedescendant', item.id);
    } else {
      item.classList.remove('active');
    }
  });
}

async function fetchSearchResults(query) {
  const response = await fetch(`/api/users/search?q=${encodeURIComponent(query)}`);
  return response.json();
}

function selectResult(result) {
  searchInput.value = result.name;
  hideResults();
}
</script>
```

---

## 7. ファイルアップロード

### ドラッグ&ドロップ対応

**Good**: プログレス表示 + プレビュー
```html
<div class="file-upload">
  <label for="file-input">
    ファイルを選択
  </label>
  <input
    type="file"
    id="file-input"
    accept="image/*"
    multiple
    hidden
    aria-describedby="file-help"
  />
  <div
    id="drop-zone"
    class="drop-zone"
    role="button"
    tabindex="0"
    aria-label="ファイルをドロップしてアップロード"
  >
    <p>ここにファイルをドロップ、またはクリックして選択</p>
  </div>
  <small id="file-help">画像ファイル（最大5MB）</small>

  <div id="file-list" class="file-list"></div>
</div>

<script>
const fileInput = document.getElementById('file-input');
const dropZone = document.getElementById('drop-zone');
const fileList = document.getElementById('file-list');

// クリックでファイル選択
dropZone.addEventListener('click', () => fileInput.click());

// ファイル選択時
fileInput.addEventListener('change', (e) => {
  handleFiles(e.target.files);
});

// ドラッグ&ドロップ
dropZone.addEventListener('dragover', (e) => {
  e.preventDefault();
  dropZone.classList.add('drag-over');
});

dropZone.addEventListener('dragleave', () => {
  dropZone.classList.remove('drag-over');
});

dropZone.addEventListener('drop', (e) => {
  e.preventDefault();
  dropZone.classList.remove('drag-over');
  handleFiles(e.dataTransfer.files);
});

function handleFiles(files) {
  Array.from(files).forEach(file => {
    if (file.size > 5 * 1024 * 1024) {
      alert(`${file.name} はサイズが大きすぎます（最大5MB）`);
      return;
    }

    uploadFile(file);
  });
}

async function uploadFile(file) {
  const fileItem = createFileItem(file);
  fileList.appendChild(fileItem);

  const formData = new FormData();
  formData.append('file', file);

  try {
    const response = await fetch('/api/upload', {
      method: 'POST',
      body: formData,
      onUploadProgress: (progressEvent) => {
        const percentCompleted = Math.round(
          (progressEvent.loaded * 100) / progressEvent.total
        );
        updateProgress(fileItem, percentCompleted);
      }
    });

    if (response.ok) {
      markAsComplete(fileItem);
    } else {
      markAsError(fileItem);
    }
  } catch (error) {
    markAsError(fileItem);
  }
}

function createFileItem(file) {
  const div = document.createElement('div');
  div.className = 'file-item';
  div.innerHTML = `
    <img class="preview" src="${URL.createObjectURL(file)}" alt="プレビュー" />
    <span class="file-name">${file.name}</span>
    <progress value="0" max="100" class="upload-progress"></progress>
    <span class="status" role="status" aria-live="polite">アップロード中...</span>
  `;
  return div;
}

function updateProgress(fileItem, percent) {
  const progress = fileItem.querySelector('.upload-progress');
  progress.value = percent;
  fileItem.querySelector('.status').textContent = `${percent}%`;
}

function markAsComplete(fileItem) {
  fileItem.querySelector('.status').textContent = '完了';
  fileItem.classList.add('complete');
}

function markAsError(fileItem) {
  fileItem.querySelector('.status').textContent = 'エラー';
  fileItem.classList.add('error');
}
</script>
```

---

## チェックリスト

### 基本構造
- [ ] すべての入力にlabelが紐付いている
- [ ] required属性とaria-required="true"を併用
- [ ] autocomplete属性を適切に設定

### バリデーション
- [ ] blur時にバリデーション実行
- [ ] エラーメッセージは具体的で明確
- [ ] aria-invalid属性で状態管理
- [ ] role="alert"でエラーを通知

### アクセシビリティ
- [ ] キーボード操作のみで完結可能
- [ ] フォーカスインジケーターが明確
- [ ] スクリーンリーダーで操作可能
- [ ] WCAG 2.1 Level AA準拠

### UX
- [ ] ローディング状態の明確な表示
- [ ] 二重送信防止
- [ ] 成功・失敗のフィードバック
- [ ] プログレス表示（複数ステップ）

---

## まとめ

このパターン集に従うことで：

- ✅ アクセシブルなフォーム
- ✅ 明確なエラーフィードバック
- ✅ 優れたユーザーエクスペリエンス
- ✅ セキュアなフォーム実装

フォーム設計・実装・レビュー時に、このガイドラインを参照してください。

---

## 参考資料

- [Web Forms - MDN](https://developer.mozilla.org/en-US/docs/Learn/Forms)
- [WCAG 2.1 - Forms](https://www.w3.org/WAI/WCAG21/Understanding/)
- [Inclusive Components - Forms](https://inclusive-components.design/)
