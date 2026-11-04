const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

function openGroup(page) {
  page.loadPath('setup_manual_oatmilk_tags');
  page.waitFor('.group-page');
  page.waitFor('.topic-preview');
}

function openTagsFilter(page) {
  openGroup(page);
  page.click('.tags-filter-menu__button');
  page.waitFor('.tags-filter-menu__card');
}

function openTagsManager(page) {
  openTagsFilter(page);
  page.clickElement('.tags-filter-menu__edit-tags');
  page.waitFor('.tags-modal');
}

function openNewDiscussion(page) {
  openGroup(page);
  page.click('.discussions-panel__new-topic-button');
  page.waitFor('.discussion-templates--template');
  page.click('.discussion-templates--template-blank');
  page.waitFor('.discussion-form');
  page.fillIn('.discussion-form__title-input input', 'Compare bottle washing suppliers');
  page.fillRichText('.discussion-form .lmo-textarea div[contenteditable=true]', richText.context('tagged-discussion', [
    'Compare local bottle washing suppliers before the returnable bottle trial begins.',
    'Check capacity, water use, food-safety records, delivery times, and service support.',
    'Share quotes and note which requirements each supplier can meet.'
  ]));
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'tags_view': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTagsFilter(page);
    screenshot.captureRegion('discussions/tags/tags_view', [
      '.discussions-panel',
      '.tags-filter-menu__card'
    ], {padding: 16, width: 1280, height: 1000});
  },

  'tags_add_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openNewDiscussion(page);
    page.click('.tags-field__input .v-field');
    page.waitFor('.v-overlay--active .v-list');
    screenshot.captureRegion('discussions/tags/tags_add_new', [
      '.discussion-form',
      '.v-overlay--active .v-list'
    ], {padding: 12, width: 1100, height: 1200});
  },

  'tags_create_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openNewDiscussion(page);
    page.click('.tags-field__input .v-field');
    page.fillIn('.tags-field__input input', 'Supplier research');
    screenshot.captureElement('discussions/tags/tags_create_new', '.discussion-form', {
      width: 1100,
      height: 1400,
      spotlight: {selector: '.discussion-form .tags-field__input', padding: 10, radius: 12}
    });
  },

  'tags_created_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openNewDiscussion(page);
    page.click('.tags-field__input .v-field');
    page.fillInAndEnter('.tags-field__input input', 'Supplier research');
    page.click('.discussion-form__title-input input');
    page.execute('document.activeElement.blur()');
    screenshot.captureElement('discussions/tags/tags_created_new', '.discussion-form', {
      width: 1100,
      height: 1200
    });
  },

  'tags_edit_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTagsFilter(page);
    screenshot.captureRegion('discussions/tags/tags_edit_new', [
      '.discussions-panel',
      '.tags-filter-menu__card'
    ], {
      spotlight: {selector: '.tags-filter-menu__edit-tags', padding: 8, radius: 12},
      padding: 16,
      width: 1280,
      height: 1000
    });
  },

  'tags_edit_new_pencil': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTagsManager(page);
    screenshot.captureElement('discussions/tags/tags_edit_new_pencil', '.tags-modal', {
      spotlight: {selector: '.tag-form__edit-tag', padding: 8, radius: 12},
      width: 1100,
      height: 1000
    });
  },

  'tags_edit_name': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTagsManager(page);
    page.clickElement('.tag-form__edit-tag');
    page.waitFor('.tags-modal__tag-name');
    page.clearField('.tags-modal__tag-name input');
    page.fillIn('.tags-modal__tag-name input', 'Cafe network');
    page.clickElement('.tag-color-button:nth-of-type(5)');
    screenshot.captureElement('discussions/tags/tags_edit_name', '.tags-modal', {
      width: 1100,
      height: 1000
    });
  },

  'tags_delete': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTagsManager(page);
    page.clickElement('.tag-form__delete');
    page.waitFor('.confirm-modal');
    screenshot.captureElement('discussions/tags/tags_delete', '.confirm-modal', {
      width: 1100,
      height: 1000
    });
  },

  'tags_global_search': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.resizeWindow(1280, 1000);
    openGroup(page);
    page.clickAndWait('.v-app-bar .navbar__search', '.search-modal');
    page.click('.search-modal .v-select .v-field');
    page.waitFor('.v-menu.v-overlay--active .v-list');
    page.execute("Array.from(document.querySelectorAll('.v-menu.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Oatmilk Cooperative')).classList.add('manual-parent-group')");
    page.click('.manual-parent-group');
    page.expectText('.search-modal', 'Any tag');
    page.execute("Array.from(document.querySelectorAll('.search-modal .v-select')).find(el => el.textContent.includes('Any tag')).setAttribute('data-manual-search-tags', '')");
    page.click('[data-manual-search-tags] .v-field');
    page.waitFor('.v-menu.v-overlay--active .v-list');
    page.execute("Array.from(document.querySelectorAll('.v-menu.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Packaging')).classList.add('manual-packaging-tag')");
    page.click('.manual-packaging-tag');
    page.waitFor('.search-results-list .v-list-item');
    page.click('[data-manual-search-tags] .v-field');
    page.waitFor('.v-menu.v-overlay--active .v-list');
    screenshot.captureRegion('discussions/tags/tags_global_search', [
      '.search-modal',
      '.v-menu.v-overlay--active .v-list'
    ], {
      width: 1280,
      height: 1000,
      padding: 24,
      clearSelection: true,
      spotlight: {selectors: ['[data-manual-search-tags]', '.v-menu.v-overlay--active .v-list'], padding: 10, radius: 14, opacity: 0.4, outlineWidth: 0}
    });
  },

  'tags_thread_sidebar': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.resizeWindow(1440, 1100);
    openGroup(page);
    page.execute("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')");
    page.clickElement('.manual-topic');
    page.waitFor('.topic-page');
    page.waitFor('.new-comment .action-menu--btn');
    page.execute("document.querySelector('.new-comment .action-menu--btn').scrollIntoView({block: 'center'})");
    page.click('.new-comment .action-menu--btn');
    page.click('.v-overlay--active .action-dock__button--edit_item_tags');
    page.waitFor('.topic-tags-dialog .topic-tags-picker__tag');
    page.execute("Array.from(document.querySelectorAll('.topic-tags-dialog .topic-tags-picker__tag')).find(el => el.textContent.includes('Sustainability')).classList.add('manual-tag')");
    page.click('.manual-tag');
    page.expectText('.thread-tags', 'Sustainability');
    page.click('.topic-tags-dialog .dismiss-modal-button');
    page.execute('window.scrollTo(0, 0)');
    screenshot.captureRegion('discussions/tags/tags_thread_sidebar', [
      '.context-panel',
      '.topic-sidebar'
    ], {
      width: 1440,
      height: 1100,
      padding: 16,
      spotlight: {selector: '.thread-tags', padding: 12, radius: 14, opacity: 0.4, outlineWidth: 0}
    });
  },

  'tags_thread_edit': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    page.execute("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')");
    page.clickElement('.manual-topic');
    page.waitFor('.topic-page');
    page.click('.topic-tags-menu__button');
    page.waitFor('.topic-tags-menu__popover');
    screenshot.captureRegion('discussions/tags/tags_thread_edit', [
      '.context-panel',
      '.topic-tags-menu__popover'
    ], {padding: 16, width: 1280, height: 1000});
  }
};
