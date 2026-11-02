import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openGroup(page) {
  await page.loadPath('setup_manual_oatmilk_tags');
  await page.waitFor('.group-page');
  await page.waitFor('.topic-preview');
}

async function openTagsFilter(page) {
  await openGroup(page);
  await page.click('.tags-filter-menu__button');
  await page.waitFor('.tags-filter-menu__card');
}

async function openTagsManager(page) {
  await openTagsFilter(page);
  await page.clickElement('.tags-filter-menu__edit-tags');
  await page.waitFor('.tags-modal');
}

async function openNewDiscussion(page) {
  await openGroup(page);
  await page.click('.discussions-panel__new-topic-button');
  await page.waitFor('.discussion-templates--template');
  await page.click('.discussion-templates--template-blank');
  await page.waitFor('.discussion-form');
  await page.fillIn('.discussion-form__title-input input', 'Compare bottle washing suppliers');
  await page.fillRichText('.discussion-form .lmo-textarea div[contenteditable=true]', richText.context('tagged-discussion', [
    'Compare local bottle washing suppliers before the returnable bottle trial begins.',
    'Check capacity, water use, food-safety records, delivery times, and service support.',
    'Share quotes and note which requirements each supplier can meet.'
  ]));
}

test('tags_view', async ({ lmo: page, manual: screenshot }) => {
  await openTagsFilter(page);
  await screenshot.captureRegion('discussions/tags/tags_view', [
    '.discussions-panel',
    '.tags-filter-menu__card'
  ], {padding: 16, width: 1280, height: 1000});
});

test('tags_add_new', async ({ lmo: page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.click('.tags-field__input .v-field');
  await page.waitFor('.v-overlay--active .v-list');
  await screenshot.captureRegion('discussions/tags/tags_add_new', [
    '.discussion-form',
    '.v-overlay--active .v-list'
  ], {padding: 12, width: 1100, height: 1200});
});

test('tags_create_new', async ({ lmo: page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.click('.tags-field__input .v-field');
  await page.fillIn('.tags-field__input input', 'Supplier research');
  await screenshot.captureElement('discussions/tags/tags_create_new', '.discussion-form', {
    width: 1100,
    height: 1400,
    spotlight: {selector: '.discussion-form .tags-field__input', padding: 10, radius: 12}
  });
});

test('tags_created_new', async ({ lmo: page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.click('.tags-field__input .v-field');
  await page.fillInAndEnter('.tags-field__input input', 'Supplier research');
  await page.click('.discussion-form__title-input input');
  await page.execute('document.activeElement.blur()');
  await screenshot.captureElement('discussions/tags/tags_created_new', '.discussion-form', {
    width: 1100,
    height: 1200
  });
});

test('tags_edit_new', async ({ lmo: page, manual: screenshot }) => {
  await openTagsFilter(page);
  await screenshot.captureRegion('discussions/tags/tags_edit_new', [
    '.discussions-panel',
    '.tags-filter-menu__card'
  ], {
    spotlight: {selector: '.tags-filter-menu__edit-tags', padding: 8, radius: 12},
    padding: 16,
    width: 1280,
    height: 1000
  });
});

test('tags_edit_new_pencil', async ({ lmo: page, manual: screenshot }) => {
  await openTagsManager(page);
  await screenshot.captureElement('discussions/tags/tags_edit_new_pencil', '.tags-modal', {
    spotlight: {selector: '.tag-form__edit-tag', padding: 8, radius: 12},
    width: 1100,
    height: 1000
  });
});

test('tags_edit_name', async ({ lmo: page, manual: screenshot }) => {
  await openTagsManager(page);
  await page.clickElement('.tag-form__edit-tag');
  await page.waitFor('.tags-modal__tag-name');
  await page.clearField('.tags-modal__tag-name input');
  await page.fillIn('.tags-modal__tag-name input', 'Cafe network');
  await page.clickElement('.tag-color-button:nth-of-type(5)');
  await screenshot.captureElement('discussions/tags/tags_edit_name', '.tags-modal', {
    width: 1100,
    height: 1000
  });
});

test('tags_delete', async ({ lmo: page, manual: screenshot }) => {
  await openTagsManager(page);
  await page.clickElement('.tag-form__delete');
  await page.waitFor('.confirm-modal');
  await screenshot.captureElement('discussions/tags/tags_delete', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});

test('tags_global_search', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1280, 1000);
  await openGroup(page);
  await page.clickAndWait('.v-app-bar .navbar__search', '.search-modal');
  await page.click('.search-modal .v-select .v-field');
  await page.waitFor('.v-menu.v-overlay--active .v-list');
  await page.execute("Array.from(document.querySelectorAll('.v-menu.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Oatmilk Cooperative')).classList.add('manual-parent-group')");
  await page.click('.manual-parent-group');
  await page.expectText('.search-modal', 'Any tag');
  await page.execute("Array.from(document.querySelectorAll('.search-modal .v-select')).find(el => el.textContent.includes('Any tag')).setAttribute('data-manual-search-tags', '')");
  await page.click('[data-manual-search-tags] .v-field');
  await page.waitFor('.v-menu.v-overlay--active .v-list');
  await page.execute("Array.from(document.querySelectorAll('.v-menu.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Packaging')).classList.add('manual-packaging-tag')");
  await page.click('.manual-packaging-tag');
  await page.waitFor('.search-results-list .v-list-item');
  await page.click('[data-manual-search-tags] .v-field');
  await page.waitFor('.v-menu.v-overlay--active .v-list');
  await screenshot.captureRegion('discussions/tags/tags_global_search', [
    '.search-modal',
    '.v-menu.v-overlay--active .v-list'
  ], {
    width: 1280,
    height: 1000,
    padding: 24,
    clearSelection: true,
    spotlight: {selectors: ['[data-manual-search-tags]', '.v-menu.v-overlay--active .v-list'], padding: 10, radius: 14, opacity: 0.4, outlineWidth: 0}
  });
});

test('tags_thread_sidebar', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1440, 1100);
  await openGroup(page);
  await page.execute("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')");
  await page.clickElement('.manual-topic');
  await page.waitFor('.topic-page');
  await page.waitFor('.new-comment .action-menu--btn');
  await page.execute("document.querySelector('.new-comment .action-menu--btn').scrollIntoView({block: 'center'})");
  await page.click('.new-comment .action-menu--btn');
  await page.click('.v-overlay--active .action-dock__button--edit_item_tags');
  await page.waitFor('.topic-tags-dialog .topic-tags-picker__tag');
  await page.execute("Array.from(document.querySelectorAll('.topic-tags-dialog .topic-tags-picker__tag')).find(el => el.textContent.includes('Sustainability')).classList.add('manual-tag')");
  await page.click('.manual-tag');
  await page.expectText('.thread-tags', 'Sustainability');
  await page.click('.topic-tags-dialog .dismiss-modal-button');
  await page.execute('window.scrollTo(0, 0)');
  await screenshot.captureRegion('discussions/tags/tags_thread_sidebar', [
    '.context-panel',
    '.topic-sidebar'
  ], {
    width: 1440,
    height: 1100,
    padding: 16,
    spotlight: {selector: '.thread-tags', padding: 12, radius: 14, opacity: 0.4, outlineWidth: 0}
  });
});

test('tags_thread_edit', async ({ lmo: page, manual: screenshot }) => {
  await openGroup(page);
  await page.execute("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')");
  await page.clickElement('.manual-topic');
  await page.waitFor('.topic-page');
  await page.click('.topic-tags-menu__button');
  await page.waitFor('.topic-tags-menu__popover');
  await screenshot.captureRegion('discussions/tags/tags_thread_edit', [
    '.context-panel',
    '.topic-tags-menu__popover'
  ], {padding: 16, width: 1280, height: 1000});
});
