# モーダル・ダイアログパターン

**最終更新**: 2025-12-15
**対象**: モーダルダイアログ設計・実装

---

## 使用方法

このドキュメントは、モーダル・ダイアログの設計・実装時に参照してください：

- **設計フェーズ**: モーダル使用の妥当性判断
- **実装フェーズ**: アクセシブルなモーダル実装
- **アクセシビリティ確認**: フォーカストラップ・キーボード操作
- **UXレビュー**: ユーザビリティ検証

---

## モーダルとダイアログの違い

| 種類 | 特徴 | 用途 |
|------|------|------|
| **モーダル** | 背景をブロック、操作必須 | 重要な確認、フォーム入力 |
| **非モーダル** | 背景操作可能 | 通知、ヘルプ |
| **アラートダイアログ** | 即座の応答が必要 | 削除確認、エラー通知 |

---

## 1. 基本モーダルダイアログ

### ✅ Good Practice

**Good**: WAI-ARIA Dialog Pattern準拠
```html
<!-- モーダルトリガー -->
<button id="open-modal" class="btn btn-primary">
  ユーザー登録
</button>

<!-- モーダルダイアログ -->
<div
  id="user-modal"
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  aria-describedby="modal-description"
  class="modal"
  hidden
>
  <div class="modal-overlay" aria-hidden="true"></div>

  <div class="modal-content">
    <!-- ヘッダー -->
    <header class="modal-header">
      <h2 id="modal-title">ユーザー登録</h2>
      <button
        type="button"
        class="close-btn"
        aria-label="閉じる"
        data-close-modal
      >
        ✕
      </button>
    </header>

    <!-- ボディ -->
    <div class="modal-body" id="modal-description">
      <form id="registration-form">
        <div class="form-group">
          <label for="name">氏名 *</label>
          <input type="text" id="name" required />
        </div>

        <div class="form-group">
          <label for="email">メールアドレス *</label>
          <input type="email" id="email" required />
        </div>
      </form>
    </div>

    <!-- フッター -->
    <footer class="modal-footer">
      <button type="button" class="btn btn-secondary" data-close-modal>
        キャンセル
      </button>
      <button type="submit" form="registration-form" class="btn btn-primary">
        登録
      </button>
    </footer>
  </div>
</div>

<style>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
}

.modal-content {
  position: relative;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  z-index: 1001;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1.5rem;
  border-top: 1px solid #e0e0e0;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  line-height: 1;
}

.close-btn:hover,
.close-btn:focus {
  background-color: #f0f0f0;
  border-radius: 4px;
  outline: 2px solid #007bff;
}
</style>

<script>
class Modal {
  constructor(modalId) {
    this.modal = document.getElementById(modalId);
    this.overlay = this.modal.querySelector('.modal-overlay');
    this.content = this.modal.querySelector('.modal-content');
    this.closeButtons = this.modal.querySelectorAll('[data-close-modal]');
    this.focusableElements = this.modal.querySelectorAll(
      'a, button, input, textarea, select, [tabindex]:not([tabindex="-1"])'
    );
    this.firstFocusable = this.focusableElements[0];
    this.lastFocusable = this.focusableElements[this.focusableElements.length - 1];
    this.previousActiveElement = null;

    this.init();
  }

  init() {
    // 閉じるボタン
    this.closeButtons.forEach(btn => {
      btn.addEventListener('click', () => this.close());
    });

    // オーバーレイクリックで閉じる
    this.overlay.addEventListener('click', () => this.close());

    // Escapeキーで閉じる
    this.modal.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.close();
      }
    });

    // フォーカストラップ
    this.modal.addEventListener('keydown', (e) => {
      if (e.key === 'Tab') {
        this.trapFocus(e);
      }
    });
  }

  open() {
    // 現在のフォーカス要素を保存
    this.previousActiveElement = document.activeElement;

    // モーダルを表示
    this.modal.hidden = false;

    // 背景スクロールを無効化
    document.body.style.overflow = 'hidden';

    // 最初のフォーカス可能要素にフォーカス
    this.firstFocusable.focus();

    // 背景のinert属性設定（モーダル外の要素を操作不可に）
    this.setInert(true);
  }

  close() {
    // モーダルを非表示
    this.modal.hidden = true;

    // 背景スクロールを有効化
    document.body.style.overflow = '';

    // フォーカスを元の要素に戻す
    if (this.previousActiveElement) {
      this.previousActiveElement.focus();
    }

    // inert属性を解除
    this.setInert(false);
  }

  trapFocus(e) {
    if (e.shiftKey) {
      // Shift + Tab
      if (document.activeElement === this.firstFocusable) {
        e.preventDefault();
        this.lastFocusable.focus();
      }
    } else {
      // Tab
      if (document.activeElement === this.lastFocusable) {
        e.preventDefault();
        this.firstFocusable.focus();
      }
    }
  }

  setInert(isInert) {
    const mainContent = document.querySelector('main');
    const header = document.querySelector('header');
    const footer = document.querySelector('footer');

    [mainContent, header, footer].forEach(element => {
      if (element) {
        if (isInert) {
          element.setAttribute('inert', '');
          element.setAttribute('aria-hidden', 'true');
        } else {
          element.removeAttribute('inert');
          element.removeAttribute('aria-hidden');
        }
      }
    });
  }
}

// 使用例
const userModal = new Modal('user-modal');

document.getElementById('open-modal').addEventListener('click', () => {
  userModal.open();
});
</script>
```

**Bad**:
```html
<!-- NG: アクセシビリティ考慮なし -->
<div id="modal" style="display:none">
  <div onclick="closeModal()">×</div>
  <div>
    <input type="text" placeholder="名前" />
    <button onclick="submit()">送信</button>
  </div>
</div>

<script>
function openModal() {
  document.getElementById('modal').style.display = 'block';
}
// フォーカストラップなし、キーボード操作不可、ARIA属性なし
</script>
```

---

## 2. アラートダイアログ（確認ダイアログ）

### 削除確認

**Good**: role="alertdialog" + 明確なアクション
```html
<div
  id="delete-dialog"
  role="alertdialog"
  aria-modal="true"
  aria-labelledby="delete-title"
  aria-describedby="delete-description"
  class="modal"
  hidden
>
  <div class="modal-overlay"></div>

  <div class="modal-content alert-dialog">
    <div class="alert-icon" aria-hidden="true">⚠️</div>

    <h2 id="delete-title">削除の確認</h2>

    <p id="delete-description">
      このユーザーを削除してもよろしいですか？<br>
      この操作は元に戻せません。
    </p>

    <div class="alert-actions">
      <button
        type="button"
        class="btn btn-secondary"
        data-action="cancel"
      >
        キャンセル
      </button>
      <button
        type="button"
        class="btn btn-danger"
        data-action="confirm"
        autofocus
      >
        削除
      </button>
    </div>
  </div>
</div>

<style>
.alert-dialog {
  text-align: center;
  padding: 2rem;
}

.alert-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.alert-actions {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-top: 2rem;
}

.btn-danger {
  background-color: #dc3545;
  color: white;
}

.btn-danger:hover {
  background-color: #c82333;
}
</style>

<script>
class AlertDialog extends Modal {
  constructor(dialogId, options = {}) {
    super(dialogId);
    this.onConfirm = options.onConfirm || (() => {});
    this.onCancel = options.onCancel || (() => {});

    this.initAlertDialog();
  }

  initAlertDialog() {
    const confirmBtn = this.modal.querySelector('[data-action="confirm"]');
    const cancelBtn = this.modal.querySelector('[data-action="cancel"]');

    confirmBtn.addEventListener('click', () => {
      this.onConfirm();
      this.close();
    });

    cancelBtn.addEventListener('click', () => {
      this.onCancel();
      this.close();
    });
  }
}

// 使用例
const deleteDialog = new AlertDialog('delete-dialog', {
  onConfirm: async () => {
    try {
      await fetch('/api/users/123', { method: 'DELETE' });
      showNotification('ユーザーを削除しました');
    } catch (error) {
      showNotification('削除に失敗しました', 'error');
    }
  }
});

// トリガー
document.getElementById('delete-user-btn').addEventListener('click', () => {
  deleteDialog.open();
});
</script>
```

---

## 3. フルスクリーンモーダル

### 複雑なフォーム・詳細表示

**Good**: モバイルフレンドリー
```html
<div
  id="fullscreen-modal"
  role="dialog"
  aria-modal="true"
  aria-labelledby="fullscreen-title"
  class="fullscreen-modal"
  hidden
>
  <div class="fullscreen-content">
    <header class="fullscreen-header">
      <button class="back-btn" aria-label="閉じる">
        ← 戻る
      </button>
      <h1 id="fullscreen-title">詳細設定</h1>
      <button class="save-btn">保存</button>
    </header>

    <main class="fullscreen-body">
      <!-- コンテンツ -->
    </main>
  </div>
</div>

<style>
.fullscreen-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 9999;
  background-color: white;
}

.fullscreen-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.fullscreen-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #e0e0e0;
  background-color: white;
  position: sticky;
  top: 0;
  z-index: 10;
}

.fullscreen-body {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
}

@media (min-width: 768px) {
  .fullscreen-modal {
    padding: 2rem;
  }

  .fullscreen-content {
    max-width: 800px;
    margin: 0 auto;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  }
}
</style>
```

---

## 4. ドロワー（サイドパネル）

### サイドから表示するモーダル

**Good**: スムーズなアニメーション
```html
<div
  id="drawer"
  role="dialog"
  aria-modal="true"
  aria-labelledby="drawer-title"
  class="drawer"
  hidden
>
  <div class="drawer-overlay"></div>

  <aside class="drawer-content" role="complementary">
    <header class="drawer-header">
      <h2 id="drawer-title">フィルター</h2>
      <button class="close-btn" aria-label="閉じる">✕</button>
    </header>

    <div class="drawer-body">
      <!-- フィルターコンテンツ -->
      <div class="filter-group">
        <h3>カテゴリ</h3>
        <label>
          <input type="checkbox" name="category" value="electronics" />
          電化製品
        </label>
        <label>
          <input type="checkbox" name="category" value="clothing" />
          衣類
        </label>
      </div>

      <div class="filter-group">
        <h3>価格帯</h3>
        <input type="range" min="0" max="100000" />
      </div>
    </div>

    <footer class="drawer-footer">
      <button class="btn btn-secondary">リセット</button>
      <button class="btn btn-primary">適用</button>
    </footer>
  </aside>
</div>

<style>
.drawer {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1000;
}

.drawer-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
}

.drawer-content {
  position: absolute;
  top: 0;
  right: -400px;
  width: 400px;
  max-width: 90%;
  height: 100%;
  background-color: white;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.1);
  transition: right 0.3s ease;
  display: flex;
  flex-direction: column;
}

.drawer.open .drawer-content {
  right: 0;
}

.drawer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
}

.drawer-body {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
}

.drawer-footer {
  display: flex;
  justify-content: space-between;
  padding: 1.5rem;
  border-top: 1px solid #e0e0e0;
}
</style>
```

---

## 5. ボトムシート（モバイル）

### モバイルネイティブ風UI

**Good**: スワイプで閉じる
```html
<div
  id="bottom-sheet"
  role="dialog"
  aria-modal="true"
  aria-labelledby="sheet-title"
  class="bottom-sheet"
  hidden
>
  <div class="sheet-overlay"></div>

  <div class="sheet-content">
    <div class="sheet-handle" aria-hidden="true"></div>

    <header class="sheet-header">
      <h2 id="sheet-title">オプション</h2>
    </header>

    <div class="sheet-body">
      <button class="sheet-option">
        <span>📤</span> 共有
      </button>
      <button class="sheet-option">
        <span>⭐</span> お気に入りに追加
      </button>
      <button class="sheet-option">
        <span>📋</span> コピー
      </button>
      <button class="sheet-option danger">
        <span>🗑️</span> 削除
      </button>
    </div>
  </div>
</div>

<style>
.bottom-sheet {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1000;
}

.sheet-content {
  position: absolute;
  bottom: -100%;
  left: 0;
  width: 100%;
  background-color: white;
  border-radius: 16px 16px 0 0;
  transition: bottom 0.3s ease;
  max-height: 80vh;
}

.bottom-sheet.open .sheet-content {
  bottom: 0;
}

.sheet-handle {
  width: 40px;
  height: 4px;
  background-color: #ccc;
  border-radius: 2px;
  margin: 12px auto;
}

.sheet-option {
  display: flex;
  align-items: center;
  gap: 1rem;
  width: 100%;
  padding: 1rem 1.5rem;
  border: none;
  background: none;
  font-size: 1rem;
  cursor: pointer;
  text-align: left;
}

.sheet-option:hover {
  background-color: #f0f0f0;
}

.sheet-option.danger {
  color: #dc3545;
}
</style>

<script>
class BottomSheet extends Modal {
  constructor(sheetId) {
    super(sheetId);
    this.initSwipe();
  }

  initSwipe() {
    let startY = 0;
    let currentY = 0;

    this.content.addEventListener('touchstart', (e) => {
      startY = e.touches[0].clientY;
    });

    this.content.addEventListener('touchmove', (e) => {
      currentY = e.touches[0].clientY;
      const diff = currentY - startY;

      if (diff > 0) {
        this.content.style.transform = `translateY(${diff}px)`;
      }
    });

    this.content.addEventListener('touchend', () => {
      const diff = currentY - startY;

      if (diff > 100) {
        this.close();
      }

      this.content.style.transform = '';
    });
  }
}
</script>
```

---

## チェックリスト

### 基本実装
- [ ] role="dialog" または role="alertdialog"
- [ ] aria-modal="true"
- [ ] aria-labelledby/aria-describedby

### フォーカス管理
- [ ] 開いたときに最初の要素にフォーカス
- [ ] フォーカストラップ実装
- [ ] 閉じたときに元の要素にフォーカス戻す

### キーボード操作
- [ ] Escapeキーで閉じる
- [ ] Tabキーでフォーカス移動
- [ ] Enterキーで決定

### 視覚的フィードバック
- [ ] オーバーレイで背景を暗く
- [ ] アニメーション（開閉）
- [ ] 明確な閉じるボタン

### アクセシビリティ
- [ ] 背景にinert属性（または aria-hidden）
- [ ] スクリーンリーダー対応
- [ ] カラーコントラスト確保

---

## まとめ

このパターン集に従うことで：

- ✅ アクセシブルなモーダル
- ✅ 優れたユーザーエクスペリエンス
- ✅ モバイルフレンドリー
- ✅ WAI-ARIA準拠

モーダル・ダイアログ設計・実装・レビュー時に、このガイドラインを参照してください。

---

## 参考資料

- [WAI-ARIA Dialog Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)
- [The Dialog Element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog)
- [Focus Management](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/)
