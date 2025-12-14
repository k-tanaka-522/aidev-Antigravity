# データ表示パターン

**最終更新**: 2025-12-15
**対象**: テーブル・カード・リスト表示

---

## 使用方法

このドキュメントは、データ表示の設計・実装時に参照してください：

- **設計フェーズ**: 表示形式の選択（テーブル/カード/リスト）
- **実装フェーズ**: レスポンシブ対応・アクセシブル実装
- **パフォーマンス**: 大量データの効率的表示
- **UXレビュー**: 可読性・操作性の検証

---

## 1. データテーブル

### 基本テーブル

**Good**: セマンティック + ソート・フィルタ機能
```html
<div class="table-container">
  <table role="table" aria-label="ユーザー一覧">
    <caption class="sr-only">
      ユーザー一覧（全150件）
    </caption>

    <thead>
      <tr>
        <th scope="col">
          <button
            class="sort-btn"
            aria-label="IDでソート"
            aria-sort="ascending"
            data-column="id"
          >
            ID
            <span class="sort-icon" aria-hidden="true">▲</span>
          </button>
        </th>
        <th scope="col">
          <button
            class="sort-btn"
            aria-label="名前でソート"
            data-column="name"
          >
            名前
            <span class="sort-icon" aria-hidden="true"></span>
          </button>
        </th>
        <th scope="col">メールアドレス</th>
        <th scope="col">登録日</th>
        <th scope="col">ステータス</th>
        <th scope="col">操作</th>
      </tr>
    </thead>

    <tbody>
      <tr>
        <td data-label="ID">001</td>
        <td data-label="名前">山田太郎</td>
        <td data-label="メールアドレス">yamada@example.com</td>
        <td data-label="登録日">
          <time datetime="2025-01-15">2025年1月15日</time>
        </td>
        <td data-label="ステータス">
          <span class="badge badge-success">有効</span>
        </td>
        <td data-label="操作">
          <button class="btn-icon" aria-label="山田太郎を編集">
            ✏️
          </button>
          <button class="btn-icon" aria-label="山田太郎を削除">
            🗑️
          </button>
        </td>
      </tr>

      <tr>
        <td data-label="ID">002</td>
        <td data-label="名前">鈴木花子</td>
        <td data-label="メールアドレス">suzuki@example.com</td>
        <td data-label="登録日">
          <time datetime="2025-02-10">2025年2月10日</time>
        </td>
        <td data-label="ステータス">
          <span class="badge badge-inactive">無効</span>
        </td>
        <td data-label="操作">
          <button class="btn-icon" aria-label="鈴木花子を編集">
            ✏️
          </button>
          <button class="btn-icon" aria-label="鈴木花子を削除">
            🗑️
          </button>
        </td>
      </tr>
    </tbody>

    <tfoot>
      <tr>
        <td colspan="6">
          <nav aria-label="テーブルページネーション" class="table-pagination">
            <button aria-label="前のページ">← 前へ</button>
            <span>1 / 8 ページ</span>
            <button aria-label="次のページ">次へ →</button>
          </nav>
        </td>
      </tr>
    </tfoot>
  </table>
</div>

<style>
.table-container {
  width: 100%;
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  border: 1px solid #e0e0e0;
}

thead {
  background-color: #f5f5f5;
}

th {
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  border-bottom: 2px solid #e0e0e0;
}

.sort-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: none;
  border: none;
  font-weight: 600;
  cursor: pointer;
  padding: 0;
}

.sort-btn:hover,
.sort-btn:focus {
  color: #007bff;
  outline: 2px solid #007bff;
  outline-offset: 2px;
}

.sort-icon {
  font-size: 0.75rem;
  color: #666;
}

td {
  padding: 1rem;
  border-bottom: 1px solid #e0e0e0;
}

tr:hover {
  background-color: #f9f9f9;
}

.badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 500;
}

.badge-success {
  background-color: #d4edda;
  color: #155724;
}

.badge-inactive {
  background-color: #f8d7da;
  color: #721c24;
}

/* レスポンシブ: モバイル表示 */
@media (max-width: 768px) {
  table,
  thead,
  tbody,
  th,
  td,
  tr {
    display: block;
  }

  thead {
    display: none;
  }

  tr {
    margin-bottom: 1rem;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
  }

  td {
    display: flex;
    justify-content: space-between;
    padding: 0.75rem 1rem;
    border: none;
  }

  td::before {
    content: attr(data-label);
    font-weight: 600;
    margin-right: 1rem;
  }

  td:last-child {
    border-bottom: none;
  }
}
</style>

<script>
// ソート機能
document.querySelectorAll('.sort-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const column = btn.dataset.column;
    const currentSort = btn.getAttribute('aria-sort');
    const newSort = currentSort === 'ascending' ? 'descending' : 'ascending';

    // すべてのソートアイコンをリセット
    document.querySelectorAll('.sort-btn').forEach(b => {
      b.removeAttribute('aria-sort');
      b.querySelector('.sort-icon').textContent = '';
    });

    // 現在のカラムをソート
    btn.setAttribute('aria-sort', newSort);
    btn.querySelector('.sort-icon').textContent = newSort === 'ascending' ? '▲' : '▼';

    // ソート処理（実際のデータソート）
    sortTableByColumn(column, newSort);
  });
});

function sortTableByColumn(column, direction) {
  // サーバーサイドソートまたはクライアントサイドソート実装
  console.log(`Sorting by ${column} in ${direction} order`);
}
</script>
```

**Bad**:
```html
<!-- NG: セマンティクスなし、レスポンシブ非対応 -->
<div>
  <div>ID | 名前 | メール</div>
  <div>001 | 山田太郎 | yamada@example.com</div>
  <div>002 | 鈴木花子 | suzuki@example.com</div>
</div>
```

---

## 2. カードレイアウト

### グリッドカード

**Good**: レスポンシブグリッド + アクセシブル
```html
<div class="card-grid">
  <article class="card" aria-labelledby="card1-title">
    <img
      src="/images/product1.jpg"
      alt="製品1の画像"
      class="card-image"
      loading="lazy"
    />

    <div class="card-content">
      <h3 id="card1-title" class="card-title">
        製品名
      </h3>

      <p class="card-description">
        製品の説明文がここに入ります。最大2行まで表示され、それ以降は省略されます。
      </p>

      <div class="card-meta">
        <span class="card-price" aria-label="価格">¥12,800</span>
        <span class="card-rating" aria-label="評価 4.5 / 5">
          ★★★★☆ (4.5)
        </span>
      </div>

      <div class="card-actions">
        <button class="btn btn-primary">
          カートに追加
        </button>
        <button class="btn-icon" aria-label="お気に入りに追加">
          ♡
        </button>
      </div>
    </div>
  </article>

  <!-- 他のカード... -->
</div>

<style>
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  padding: 1.5rem;
}

.card {
  background-color: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
  transition: transform 0.2s, box-shadow 0.2s;
}

.card:hover,
.card:focus-within {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.card-content {
  padding: 1.5rem;
}

.card-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.card-description {
  color: #666;
  margin: 0 0 1rem 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.card-price {
  font-size: 1.5rem;
  font-weight: 700;
  color: #007bff;
}

.card-rating {
  color: #ffc107;
}

.card-actions {
  display: flex;
  gap: 0.5rem;
}

.card-actions .btn {
  flex: 1;
}

@media (max-width: 768px) {
  .card-grid {
    grid-template-columns: 1fr;
  }
}
</style>
```

---

## 3. リスト表示

### インタラクティブリスト

**Good**: 選択可能リスト + キーボード操作
```html
<div class="list-container">
  <ul
    role="listbox"
    aria-label="ユーザー選択"
    aria-multiselectable="false"
    class="interactive-list"
  >
    <li
      role="option"
      aria-selected="true"
      tabindex="0"
      class="list-item selected"
    >
      <div class="list-avatar" aria-hidden="true">
        <img src="/avatars/user1.jpg" alt="" />
      </div>

      <div class="list-content">
        <h4 class="list-title">山田太郎</h4>
        <p class="list-subtitle">yamada@example.com</p>
      </div>

      <div class="list-actions">
        <span class="badge badge-online">オンライン</span>
        <button class="btn-icon" aria-label="山田太郎にメッセージを送る">
          💬
        </button>
      </div>
    </li>

    <li
      role="option"
      aria-selected="false"
      tabindex="-1"
      class="list-item"
    >
      <div class="list-avatar" aria-hidden="true">
        <img src="/avatars/user2.jpg" alt="" />
      </div>

      <div class="list-content">
        <h4 class="list-title">鈴木花子</h4>
        <p class="list-subtitle">suzuki@example.com</p>
      </div>

      <div class="list-actions">
        <span class="badge badge-offline">オフライン</span>
        <button class="btn-icon" aria-label="鈴木花子にメッセージを送る">
          💬
        </button>
      </div>
    </li>
  </ul>
</div>

<style>
.interactive-list {
  list-style: none;
  padding: 0;
  margin: 0;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
}

.list-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  cursor: pointer;
  border-bottom: 1px solid #e0e0e0;
  transition: background-color 0.2s;
}

.list-item:last-child {
  border-bottom: none;
}

.list-item:hover,
.list-item:focus {
  background-color: #f5f5f5;
  outline: 2px solid #007bff;
  outline-offset: -2px;
}

.list-item.selected {
  background-color: #e7f3ff;
}

.list-avatar {
  flex-shrink: 0;
}

.list-avatar img {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
}

.list-content {
  flex: 1;
  min-width: 0;
}

.list-title {
  margin: 0 0 0.25rem 0;
  font-size: 1rem;
  font-weight: 600;
}

.list-subtitle {
  margin: 0;
  font-size: 0.875rem;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.list-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.badge-online {
  background-color: #d4edda;
  color: #155724;
}

.badge-offline {
  background-color: #f8d7da;
  color: #721c24;
}
</style>

<script>
const listbox = document.querySelector('[role="listbox"]');
const items = listbox.querySelectorAll('[role="option"]');

items.forEach((item, index) => {
  // クリックで選択
  item.addEventListener('click', () => {
    selectItem(item);
  });

  // キーボード操作
  item.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      selectItem(item);
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      const nextItem = items[index + 1] || items[0];
      nextItem.focus();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      const prevItem = items[index - 1] || items[items.length - 1];
      prevItem.focus();
    }
  });
});

function selectItem(item) {
  // すべての選択を解除
  items.forEach(i => {
    i.setAttribute('aria-selected', 'false');
    i.classList.remove('selected');
    i.tabIndex = -1;
  });

  // 選択された項目をアクティブに
  item.setAttribute('aria-selected', 'true');
  item.classList.add('selected');
  item.tabIndex = 0;
}
</script>
```

---

## 4. 仮想スクロール（大量データ）

### 効率的なレンダリング

**Good**: Intersection Observer + 仮想化
```html
<div class="virtual-list-container">
  <div
    class="virtual-list"
    role="list"
    aria-label="大量データリスト"
    style="height: 500px; overflow-y: auto;"
  >
    <div class="virtual-spacer-top" style="height: 0px;"></div>

    <!-- 表示中のアイテムのみレンダリング -->
    <div
      class="virtual-item"
      role="listitem"
      data-index="0"
    >
      アイテム 0
    </div>

    <div class="virtual-spacer-bottom" style="height: 0px;"></div>
  </div>
</div>

<script>
class VirtualList {
  constructor(container, options = {}) {
    this.container = container;
    this.itemHeight = options.itemHeight || 50;
    this.totalItems = options.totalItems || 10000;
    this.visibleItems = Math.ceil(container.clientHeight / this.itemHeight) + 5;
    this.scrollTop = 0;

    this.spacerTop = container.querySelector('.virtual-spacer-top');
    this.spacerBottom = container.querySelector('.virtual-spacer-bottom');

    this.container.addEventListener('scroll', () => this.handleScroll());
    this.render();
  }

  handleScroll() {
    this.scrollTop = this.container.scrollTop;
    this.render();
  }

  render() {
    const startIndex = Math.floor(this.scrollTop / this.itemHeight);
    const endIndex = Math.min(
      startIndex + this.visibleItems,
      this.totalItems
    );

    // スペーサーの高さ調整
    this.spacerTop.style.height = `${startIndex * this.itemHeight}px`;
    this.spacerBottom.style.height = `${
      (this.totalItems - endIndex) * this.itemHeight
    }px`;

    // アイテムレンダリング
    const fragment = document.createDocumentFragment();

    for (let i = startIndex; i < endIndex; i++) {
      const item = this.createItem(i);
      fragment.appendChild(item);
    }

    // 既存のアイテムを削除して新しいものを挿入
    const existingItems = this.container.querySelectorAll('.virtual-item');
    existingItems.forEach(item => item.remove());

    this.spacerTop.after(fragment);
  }

  createItem(index) {
    const div = document.createElement('div');
    div.className = 'virtual-item';
    div.role = 'listitem';
    div.dataset.index = index;
    div.style.height = `${this.itemHeight}px`;
    div.textContent = `アイテム ${index}`;
    return div;
  }
}

// 使用例
const container = document.querySelector('.virtual-list');
new VirtualList(container, {
  itemHeight: 50,
  totalItems: 10000
});
</script>
```

---

## 5. データグリッド（高度なテーブル）

### 編集可能グリッド

**Good**: インラインエディット + バリデーション
```html
<div
  role="grid"
  aria-label="編集可能データグリッド"
  class="data-grid"
>
  <div role="rowgroup">
    <div role="row" class="grid-header">
      <div role="columnheader">ID</div>
      <div role="columnheader">名前</div>
      <div role="columnheader">メール</div>
      <div role="columnheader">操作</div>
    </div>
  </div>

  <div role="rowgroup">
    <div role="row" class="grid-row" data-row-id="1">
      <div role="gridcell">001</div>

      <div role="gridcell" aria-readonly="false" tabindex="0">
        <span class="cell-value">山田太郎</span>
        <input class="cell-editor" type="text" value="山田太郎" hidden />
      </div>

      <div role="gridcell" aria-readonly="false" tabindex="-1">
        <span class="cell-value">yamada@example.com</span>
        <input class="cell-editor" type="email" value="yamada@example.com" hidden />
      </div>

      <div role="gridcell">
        <button class="btn-sm btn-save" disabled>保存</button>
        <button class="btn-sm btn-cancel" disabled>キャンセル</button>
      </div>
    </div>
  </div>
</div>

<script>
document.querySelectorAll('[role="gridcell"][aria-readonly="false"]').forEach(cell => {
  const value = cell.querySelector('.cell-value');
  const editor = cell.querySelector('.cell-editor');

  // ダブルクリックまたはEnterで編集モード
  cell.addEventListener('dblclick', () => enterEditMode(cell));
  cell.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      enterEditMode(cell);
    }
  });

  function enterEditMode(cell) {
    value.hidden = true;
    editor.hidden = false;
    editor.focus();
    editor.select();

    // 保存・キャンセルボタンを有効化
    const row = cell.closest('[role="row"]');
    row.querySelectorAll('.btn-save, .btn-cancel').forEach(btn => {
      btn.disabled = false;
    });
  }

  function exitEditMode(cell, save = false) {
    if (save) {
      value.textContent = editor.value;
      // サーバーに保存処理
    } else {
      editor.value = value.textContent;
    }

    value.hidden = false;
    editor.hidden = true;

    const row = cell.closest('[role="row"]');
    row.querySelectorAll('.btn-save, .btn-cancel').forEach(btn => {
      btn.disabled = true;
    });
  }

  // Enterで保存、Escapeでキャンセル
  editor.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      exitEditMode(cell, true);
    } else if (e.key === 'Escape') {
      exitEditMode(cell, false);
      cell.focus();
    }
  });
});
</script>
```

---

## チェックリスト

### テーブル
- [ ] `<table>`, `<thead>`, `<tbody>` を正しく使用
- [ ] `<th scope="col/row">` でヘッダー定義
- [ ] caption または aria-label で説明
- [ ] レスポンシブ対応（モバイル表示）

### カード
- [ ] `<article>` で各カードをマークアップ
- [ ] 画像に適切な alt 属性
- [ ] loading="lazy" で遅延読み込み
- [ ] グリッドレイアウト（レスポンシブ）

### リスト
- [ ] `<ul>`, `<ol>`, `<li>` を使用
- [ ] role="listbox" でインタラクティブリスト
- [ ] キーボード操作対応（矢印キー）
- [ ] aria-selected で選択状態管理

### パフォーマンス
- [ ] 大量データは仮想スクロール
- [ ] Intersection Observer で遅延ロード
- [ ] ページネーションまたは無限スクロール

---

## まとめ

このパターン集に従うことで：

- ✅ アクセシブルなデータ表示
- ✅ レスポンシブデザイン
- ✅ 高パフォーマンス
- ✅ 優れたユーザーエクスペリエンス

データ表示設計・実装・レビュー時に、このガイドラインを参照してください。

---

## 参考資料

- [WAI-ARIA Table Patterns](https://www.w3.org/WAI/ARIA/apg/patterns/table/)
- [Responsive Tables](https://css-tricks.com/responsive-data-tables/)
- [Virtual Scrolling](https://web.dev/virtualize-long-lists-react-window/)
