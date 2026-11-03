import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { itemAction, openThreadForm } from '../helpers/threads.mjs';
import { choose } from '../helpers/vuetify.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

const thread = page => page.locator('.topic-preview', { hasText: 'Returnable bottles for cafe customers' });
const tagsInput = page => page.locator('.tags-field__input input');

async function openGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_tags');
  await expect(thread(page)).toBeVisible();
}

async function openTagsFilter(page) {
  await openGroup(page);
  await page.locator('.tags-filter-menu__button').click();
  await expect(page.locator('.tags-filter-menu__card')).toBeVisible();
}

async function openTagsManager(page) {
  await openTagsFilter(page);
  await page.locator('.tags-filter-menu__edit-tags').click();
  await expect(page.locator('.tags-modal')).toBeVisible();
}

async function openNewDiscussion(page) {
  await openGroup(page);
  await openThreadForm(page);
  const form = page.locator('.discussion-form');
  await form.locator('.discussion-form__title-input input').fill('Compare bottle washing suppliers');
  await editor(form).evaluate((element, html) => {
    element.focus();
    element.innerHTML = html;
    element.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }));
  }, richText.context('tagged-discussion', [
    'Compare local bottle washing suppliers before the returnable bottle trial begins.',
    'Check capacity, water use, food-safety records, delivery times, and service support.',
    'Share quotes and note which requirements each supplier can meet.'
  ]));
}

test('tags_view', async ({ page, manual: screenshot }) => {
  await openTagsFilter(page);
  await screenshot.captureRegion('discussions/tags/tags_view', [
    '.discussions-panel',
    '.tags-filter-menu__card'
  ], {padding: 16, width: 1280, height: 1000});
});

test('tags_add_new', async ({ page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.locator('.tags-field__input .v-field').click();
  await expect(page.locator('.v-overlay--active .v-list')).toBeVisible();
  await screenshot.captureRegion('discussions/tags/tags_add_new', [
    '.discussion-form',
    '.v-overlay--active .v-list'
  ], {padding: 12, width: 1100, height: 1200});
});

test('tags_create_new', async ({ page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.locator('.tags-field__input .v-field').click();
  await tagsInput(page).fill('Supplier research');
  await screenshot.captureElement('discussions/tags/tags_create_new', '.discussion-form', {
    width: 1100,
    height: 1400,
    spotlight: {selector: '.discussion-form .tags-field__input', padding: 10, radius: 12}
  });
});

test('tags_created_new', async ({ page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.locator('.tags-field__input .v-field').click();
  await tagsInput(page).fill('Supplier research');
  await tagsInput(page).press('Enter');
  // Close the tag menu, then leave no field focused.
  const title = page.locator('.discussion-form__title-input input');
  await title.click();
  await title.blur();
  await screenshot.captureElement('discussions/tags/tags_created_new', '.discussion-form', {
    width: 1100,
    height: 1200
  });
});

test('tags_edit_new', async ({ page, manual: screenshot }) => {
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

test('tags_edit_new_pencil', async ({ page, manual: screenshot }) => {
  await openTagsManager(page);
  await screenshot.captureElement('discussions/tags/tags_edit_new_pencil', '.tags-modal', {
    spotlight: {selector: '.tag-form__edit-tag', padding: 8, radius: 12},
    width: 1100,
    height: 1000
  });
});

test('tags_edit_name', async ({ page, manual: screenshot }) => {
  await openTagsManager(page);
  // The first tag, as in the image of its pencil.
  await page.locator('.tag-form__edit-tag').first().click();
  await page.locator('.tags-modal__tag-name input').fill('Cafe network');
  // Indigo.
  await page.locator('.tag-color-button[title="#3f51b5"]').click();
  await screenshot.captureElement('discussions/tags/tags_edit_name', '.tags-modal', {
    width: 1100,
    height: 1000
  });
});

test('tags_delete', async ({ page, manual: screenshot }) => {
  await openTagsManager(page);
  await page.locator('.tag-form__delete').first().click();
  await expect(page.locator('.confirm-modal')).toBeVisible();
  await screenshot.captureElement('discussions/tags/tags_delete', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});

test('tags_global_search', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1280, height: 1000 });
  await openGroup(page);
  await page.locator('.v-app-bar .navbar__search').click();
  await choose(page, '.search-modal__organization', 'Oatmilk Cooperative');
  await expectLabel(page.locator('.search-modal__tag'), 'Any tag');
  await choose(page, '.search-modal__tag', 'Packaging');
  // Any result shows the search has run.
  await expect(page.locator('.search-results-list .v-list-item').first()).toBeVisible();
  await page.locator('.search-modal__tag .v-field').click();
  await expect(page.locator('.v-menu.v-overlay--active .v-list')).toBeVisible();
  await screenshot.captureRegion('discussions/tags/tags_global_search', [
    '.search-modal',
    '.v-menu.v-overlay--active .v-list'
  ], {
    width: 1280,
    height: 1000,
    padding: 24,
    clearSelection: true,
    spotlight: {selectors: ['.search-modal__tag', '.v-menu.v-overlay--active .v-list'], padding: 10, radius: 14, opacity: 0.4, outlineWidth: 0}
  });
});

test('tags_thread_sidebar', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1440, height: 1100 });
  await openGroup(page);
  await thread(page).locator('.topic-preview__title').click();
  await itemAction(page, page.locator('.new-comment'), 'edit_item_tags');
  await page.locator('.topic-tags-dialog .topic-tags-picker__tag', { hasText: 'Sustainability' }).click();
  await expectLabel(page.locator('.thread-tags'), 'Sustainability');
  await page.locator('.topic-tags-dialog .dismiss-modal-button').click();
  await page.evaluate(() => window.scrollTo(0, 0));
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

test('tags_thread_edit', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await thread(page).locator('.topic-preview__title').click();
  await page.locator('.topic-header .topic-tags-menu__button').click();
  await expect(page.locator('.topic-tags-menu__popover')).toBeVisible();
  await screenshot.captureRegion('discussions/tags/tags_thread_edit', [
    '.context-panel',
    '.topic-tags-menu__popover'
  ], {padding: 16, width: 1280, height: 1000});
});
