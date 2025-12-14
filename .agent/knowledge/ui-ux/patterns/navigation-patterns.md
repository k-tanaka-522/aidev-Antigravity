# ナビゲーションパターン

**最終更新**: 2025-12-15
**対象**: Webナビゲーション設計・実装

---

## 使用方法

このドキュメントは、ナビゲーション設計・実装時に参照してください：

- **設計フェーズ**: サイト構造とナビゲーション方式の決定
- **実装フェーズ**: アクセシブルなナビゲーション実装
- **レスポンシブ対応**: モバイル/デスクトップの切り替え
- **アクセシビリティ確認**: キーボード・スクリーンリーダー対応

---

## 1. プライマリナビゲーション（グローバルナビ）

### デスクトップ用水平ナビゲーション

**Good**: セマンティックHTML + ARIAランドマーク
```html
<header>
  <nav aria-label="メインナビゲーション" class="primary-nav">
    <ul role="menubar" class="nav-list">
      <li role="none">
        <a href="/" role="menuitem" aria-current="page">
          ホーム
        </a>
      </li>
      <li role="none">
        <a
          href="#"
          role="menuitem"
          aria-haspopup="true"
          aria-expanded="false"
          id="products-btn"
        >
          製品
        </a>
        <!-- ドロップダウンメニュー -->
        <ul role="menu" aria-labelledby="products-btn" class="dropdown" hidden>
          <li role="none">
            <a href="/products/software" role="menuitem">ソフトウェア</a>
          </li>
          <li role="none">
            <a href="/products/hardware" role="menuitem">ハードウェア</a>
          </li>
          <li role="none">
            <a href="/products/services" role="menuitem">サービス</a>
          </li>
        </ul>
      </li>
      <li role="none">
        <a href="/about" role="menuitem">会社情報</a>
      </li>
      <li role="none">
        <a href="/contact" role="menuitem">お問い合わせ</a>
      </li>
    </ul>
  </nav>
</header>

<style>
.primary-nav {
  background-color: #333;
}

.nav-list {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-list > li {
  position: relative;
}

.nav-list a {
  display: block;
  padding: 1rem 1.5rem;
  color: white;
  text-decoration: none;
}

.nav-list a:hover,
.nav-list a:focus {
  background-color: #555;
  outline: 2px solid #fff;
  outline-offset: -2px;
}

.nav-list a[aria-current="page"] {
  background-color: #007bff;
  font-weight: bold;
}

.dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  background-color: #444;
  min-width: 200px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  list-style: none;
  padding: 0;
  margin: 0;
}

.dropdown a {
  padding: 0.75rem 1rem;
}
</style>

<script>
// ドロップダウンメニューの制御
document.querySelectorAll('[aria-haspopup="true"]').forEach(trigger => {
  const dropdown = trigger.nextElementSibling;

  // クリックで開閉
  trigger.addEventListener('click', (e) => {
    e.preventDefault();
    toggleDropdown(trigger, dropdown);
  });

  // キーボード操作
  trigger.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      toggleDropdown(trigger, dropdown);
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      openDropdown(trigger, dropdown);
      dropdown.querySelector('a').focus();
    }
  });

  // ドロップダウン内のキーボードナビゲーション
  dropdown.querySelectorAll('a').forEach((item, index, items) => {
    item.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        const nextItem = items[index + 1] || items[0];
        nextItem.focus();
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        const prevItem = items[index - 1] || items[items.length - 1];
        prevItem.focus();
      } else if (e.key === 'Escape') {
        closeDropdown(trigger, dropdown);
        trigger.focus();
      }
    });
  });
});

// 外側クリックで閉じる
document.addEventListener('click', (e) => {
  if (!e.target.closest('.primary-nav')) {
    closeAllDropdowns();
  }
});

function toggleDropdown(trigger, dropdown) {
  const isExpanded = trigger.getAttribute('aria-expanded') === 'true';
  if (isExpanded) {
    closeDropdown(trigger, dropdown);
  } else {
    closeAllDropdowns();
    openDropdown(trigger, dropdown);
  }
}

function openDropdown(trigger, dropdown) {
  trigger.setAttribute('aria-expanded', 'true');
  dropdown.hidden = false;
}

function closeDropdown(trigger, dropdown) {
  trigger.setAttribute('aria-expanded', 'false');
  dropdown.hidden = true;
}

function closeAllDropdowns() {
  document.querySelectorAll('[aria-haspopup="true"]').forEach(trigger => {
    const dropdown = trigger.nextElementSibling;
    closeDropdown(trigger, dropdown);
  });
}
</script>
```

**Bad**:
```html
<!-- NG: セマンティクスなし、アクセシビリティ考慮なし -->
<div class="nav">
  <div onclick="location.href='/'">ホーム</div>
  <div onclick="showMenu()">製品</div>
  <div onclick="location.href='/about'">会社情報</div>
</div>
```

---

## 2. モバイルナビゲーション（ハンバーガーメニュー）

### レスポンシブ対応メニュー

**Good**: スライドインメニュー + フォーカストラップ
```html
<header>
  <button
    class="menu-toggle"
    aria-label="メニューを開く"
    aria-expanded="false"
    aria-controls="mobile-menu"
  >
    <span class="hamburger-icon" aria-hidden="true">
      <span></span>
      <span></span>
      <span></span>
    </span>
  </button>

  <nav id="mobile-menu" class="mobile-nav" aria-label="モバイルナビゲーション" hidden>
    <button class="close-btn" aria-label="メニューを閉じる">
      ✕
    </button>

    <ul class="mobile-nav-list">
      <li>
        <a href="/" aria-current="page">ホーム</a>
      </li>
      <li>
        <button aria-expanded="false" aria-controls="mobile-products">
          製品
        </button>
        <ul id="mobile-products" class="submenu" hidden>
          <li><a href="/products/software">ソフトウェア</a></li>
          <li><a href="/products/hardware">ハードウェア</a></li>
          <li><a href="/products/services">サービス</a></li>
        </ul>
      </li>
      <li>
        <a href="/about">会社情報</a>
      </li>
      <li>
        <a href="/contact">お問い合わせ</a>
      </li>
    </ul>
  </nav>

  <!-- オーバーレイ -->
  <div class="menu-overlay" hidden aria-hidden="true"></div>
</header>

<style>
.menu-toggle {
  display: none;
  background: none;
  border: none;
  padding: 1rem;
  cursor: pointer;
}

.hamburger-icon span {
  display: block;
  width: 25px;
  height: 3px;
  background-color: #333;
  margin: 5px 0;
  transition: 0.3s;
}

.mobile-nav {
  position: fixed;
  top: 0;
  right: -300px;
  width: 300px;
  height: 100vh;
  background-color: white;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.1);
  transition: right 0.3s ease;
  z-index: 1000;
  overflow-y: auto;
}

.mobile-nav.open {
  right: 0;
}

.menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

@media (max-width: 768px) {
  .menu-toggle {
    display: block;
  }

  .primary-nav {
    display: none;
  }
}
</style>

<script>
const menuToggle = document.querySelector('.menu-toggle');
const mobileMenu = document.getElementById('mobile-menu');
const closeBtn = mobileMenu.querySelector('.close-btn');
const overlay = document.querySelector('.menu-overlay');
const focusableElements = mobileMenu.querySelectorAll(
  'a, button, [tabindex]:not([tabindex="-1"])'
);
const firstFocusable = focusableElements[0];
const lastFocusable = focusableElements[focusableElements.length - 1];

// メニューを開く
menuToggle.addEventListener('click', () => {
  openMenu();
});

// メニューを閉じる
closeBtn.addEventListener('click', () => {
  closeMenu();
});

overlay.addEventListener('click', () => {
  closeMenu();
});

// Escapeキーで閉じる
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && !mobileMenu.hidden) {
    closeMenu();
  }
});

// フォーカストラップ
mobileMenu.addEventListener('keydown', (e) => {
  if (e.key === 'Tab') {
    if (e.shiftKey) {
      // Shift + Tab
      if (document.activeElement === firstFocusable) {
        e.preventDefault();
        lastFocusable.focus();
      }
    } else {
      // Tab
      if (document.activeElement === lastFocusable) {
        e.preventDefault();
        firstFocusable.focus();
      }
    }
  }
});

function openMenu() {
  mobileMenu.hidden = false;
  mobileMenu.classList.add('open');
  overlay.hidden = false;
  menuToggle.setAttribute('aria-expanded', 'true');
  menuToggle.setAttribute('aria-label', 'メニューを閉じる');

  // スクロール無効化
  document.body.style.overflow = 'hidden';

  // フォーカスを閉じるボタンに移動
  closeBtn.focus();
}

function closeMenu() {
  mobileMenu.hidden = true;
  mobileMenu.classList.remove('open');
  overlay.hidden = true;
  menuToggle.setAttribute('aria-expanded', 'false');
  menuToggle.setAttribute('aria-label', 'メニューを開く');

  // スクロール有効化
  document.body.style.overflow = '';

  // フォーカスをトグルボタンに戻す
  menuToggle.focus();
}

// サブメニュー展開
mobileMenu.querySelectorAll('button[aria-controls]').forEach(btn => {
  btn.addEventListener('click', () => {
    const submenu = document.getElementById(btn.getAttribute('aria-controls'));
    const isExpanded = btn.getAttribute('aria-expanded') === 'true';

    btn.setAttribute('aria-expanded', !isExpanded);
    submenu.hidden = isExpanded;
  });
});
</script>
```

---

## 3. パンくずリスト

### 階層構造の明示

**Good**: 構造化データ + ARIA
```html
<nav aria-label="パンくずリスト">
  <ol class="breadcrumb" itemscope itemtype="https://schema.org/BreadcrumbList">
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="/">
        <span itemprop="name">ホーム</span>
      </a>
      <meta itemprop="position" content="1" />
    </li>

    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="/products">
        <span itemprop="name">製品</span>
      </a>
      <meta itemprop="position" content="2" />
    </li>

    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="/products/software" aria-current="page">
        <span itemprop="name">ソフトウェア</span>
      </a>
      <meta itemprop="position" content="3" />
    </li>
  </ol>
</nav>

<style>
.breadcrumb {
  display: flex;
  list-style: none;
  padding: 1rem 0;
  margin: 0;
}

.breadcrumb li:not(:last-child)::after {
  content: '/';
  margin: 0 0.5rem;
  color: #666;
}

.breadcrumb a {
  color: #007bff;
  text-decoration: none;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.breadcrumb a[aria-current="page"] {
  color: #333;
  font-weight: bold;
  pointer-events: none;
}
</style>
```

**Bad**:
```html
<!-- NG: セマンティクスなし -->
<div class="breadcrumb">
  <span>ホーム > 製品 > ソフトウェア</span>
</div>
```

---

## 4. タブナビゲーション

### コンテンツ切り替えタブ

**Good**: WAI-ARIA Tabs Pattern準拠
```html
<div class="tabs-container">
  <div role="tablist" aria-label="製品カテゴリ">
    <button
      role="tab"
      aria-selected="true"
      aria-controls="tab1-panel"
      id="tab1"
      tabindex="0"
    >
      概要
    </button>
    <button
      role="tab"
      aria-selected="false"
      aria-controls="tab2-panel"
      id="tab2"
      tabindex="-1"
    >
      仕様
    </button>
    <button
      role="tab"
      aria-selected="false"
      aria-controls="tab3-panel"
      id="tab3"
      tabindex="-1"
    >
      レビュー
    </button>
  </div>

  <div role="tabpanel" id="tab1-panel" aria-labelledby="tab1">
    <h2>概要</h2>
    <p>製品の概要説明...</p>
  </div>

  <div role="tabpanel" id="tab2-panel" aria-labelledby="tab2" hidden>
    <h2>仕様</h2>
    <p>製品の仕様...</p>
  </div>

  <div role="tabpanel" id="tab3-panel" aria-labelledby="tab3" hidden>
    <h2>レビュー</h2>
    <p>ユーザーレビュー...</p>
  </div>
</div>

<script>
const tabs = document.querySelectorAll('[role="tab"]');
const panels = document.querySelectorAll('[role="tabpanel"]');

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    switchTab(tab);
  });

  tab.addEventListener('keydown', (e) => {
    const currentIndex = Array.from(tabs).indexOf(tab);

    if (e.key === 'ArrowRight') {
      e.preventDefault();
      const nextTab = tabs[currentIndex + 1] || tabs[0];
      switchTab(nextTab);
      nextTab.focus();
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      const prevTab = tabs[currentIndex - 1] || tabs[tabs.length - 1];
      switchTab(prevTab);
      prevTab.focus();
    } else if (e.key === 'Home') {
      e.preventDefault();
      switchTab(tabs[0]);
      tabs[0].focus();
    } else if (e.key === 'End') {
      e.preventDefault();
      switchTab(tabs[tabs.length - 1]);
      tabs[tabs.length - 1].focus();
    }
  });
});

function switchTab(selectedTab) {
  // すべてのタブを非選択に
  tabs.forEach(tab => {
    tab.setAttribute('aria-selected', 'false');
    tab.setAttribute('tabindex', '-1');
  });

  // すべてのパネルを非表示に
  panels.forEach(panel => {
    panel.hidden = true;
  });

  // 選択されたタブとパネルを表示
  selectedTab.setAttribute('aria-selected', 'true');
  selectedTab.setAttribute('tabindex', '0');

  const panelId = selectedTab.getAttribute('aria-controls');
  const panel = document.getElementById(panelId);
  panel.hidden = false;
}
</script>
```

---

## 5. ページネーション

### ページ送りナビゲーション

**Good**: 現在ページの明示 + アクセシブル
```html
<nav aria-label="ページネーション">
  <ul class="pagination">
    <li>
      <a href="?page=1" aria-label="前のページ" rel="prev">
        ← 前へ
      </a>
    </li>

    <li>
      <a href="?page=1">1</a>
    </li>

    <li>
      <a href="?page=2" aria-current="page" aria-label="現在のページ, ページ 2">
        2
      </a>
    </li>

    <li>
      <a href="?page=3">3</a>
    </li>

    <li aria-hidden="true">
      <span>...</span>
    </li>

    <li>
      <a href="?page=10">10</a>
    </li>

    <li>
      <a href="?page=3" aria-label="次のページ" rel="next">
        次へ →
      </a>
    </li>
  </ul>
</nav>

<style>
.pagination {
  display: flex;
  list-style: none;
  padding: 0;
  gap: 0.5rem;
}

.pagination a {
  display: block;
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  color: #007bff;
  text-decoration: none;
}

.pagination a:hover,
.pagination a:focus {
  background-color: #f0f0f0;
  outline: 2px solid #007bff;
  outline-offset: 2px;
}

.pagination a[aria-current="page"] {
  background-color: #007bff;
  color: white;
  font-weight: bold;
  pointer-events: none;
}
</style>
```

---

## チェックリスト

### セマンティクス
- [ ] `<nav>`要素を使用
- [ ] aria-label/aria-labelledbyで目的を明示
- [ ] 適切なランドマーク（role）設定

### キーボードアクセシビリティ
- [ ] Tabキーでフォーカス移動可能
- [ ] Enterキー/Spaceキーで選択
- [ ] 矢印キーでメニュー内移動（該当する場合）
- [ ] Escapeキーでメニュー閉じる

### 視覚的フィードバック
- [ ] 現在位置を aria-current="page" で明示
- [ ] フォーカスインジケーターが明確
- [ ] ホバー/フォーカス状態の視覚的変化

### モバイル対応
- [ ] レスポンシブデザイン
- [ ] タッチターゲット最小44x44px
- [ ] スクロール時の固定ヘッダー

---

## まとめ

このパターン集に従うことで：

- ✅ アクセシブルなナビゲーション
- ✅ SEO向上（構造化データ）
- ✅ 優れたユーザーエクスペリエンス
- ✅ レスポンシブ対応

ナビゲーション設計・実装・レビュー時に、このガイドラインを参照してください。

---

## 参考資料

- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [Inclusive Components - Menus](https://inclusive-components.design/menus-menu-buttons/)
- [WebAIM - Navigation](https://webaim.org/techniques/navigation/)
