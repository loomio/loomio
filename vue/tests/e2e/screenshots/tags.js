const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openGroup(page) {
  page.loadPath('setup_manual_oatmilk_tags');
  page.waitFor('.group-page');
  page.waitFor('.thread-preview');
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
  page.click('.discussions-panel__new-thread-button');
  page.waitFor('.discussion-templates--template');
  page.execute("Array.from(document.querySelectorAll('.discussion-templates--template')).find(el => el.textContent.includes('Blank')).click()");
  page.waitFor('.discussion-form');
  page.fillIn('.discussion-form__title-input input', 'Compare bottle washing suppliers');
  page.fillIn('.discussion-form .lmo-textarea div[contenteditable=true]', 'Compare capacity, water use, delivery times, and service support.');
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
    screenshot.captureRegion('discussions/tags/tags_create_new', ['.tags-field__input'], {
      padding: 24,
      width: 1100,
      height: 1000
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

  'tags_thread_edit': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    page.execute("Array.from(document.querySelectorAll('.thread-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-thread')");
    page.clickElement('.manual-thread');
    page.waitFor('.strand-page');
    page.click('.topic-tags-menu__button');
    page.waitFor('.topic-tags-menu__popover');
    screenshot.captureRegion('discussions/tags/tags_thread_edit', [
      '.context-panel',
      '.topic-tags-menu__popover'
    ], {padding: 16, width: 1280, height: 1000});
  }
};
