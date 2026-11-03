import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_tags')
  await expect(page.locator('.group-page').first()).toBeVisible()
  await expect(page.locator('.topic-preview').first()).toBeVisible()
}

async function openTagsFilter(page) {
  await openGroup(page);
  await page.locator('.tags-filter-menu__button').click()
  await expect(page.locator('.tags-filter-menu__card').first()).toBeVisible()
}

async function openTagsManager(page) {
  await openTagsFilter(page);
  await page.locator('.tags-filter-menu__edit-tags').click()
  await expect(page.locator('.tags-modal').first()).toBeVisible()
}

async function openNewDiscussion(page) {
  await openGroup(page);
  await page.locator('.discussions-panel__new-topic-button').click()
  await expect(page.locator('.discussion-templates--template').first()).toBeVisible()
  await page.locator('.discussion-templates--template-blank').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await page.locator('.discussion-form__title-input input').fill('Compare bottle washing suppliers')
  await page.locator('.discussion-form .lmo-textarea div[contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('tagged-discussion', [
    'Compare local bottle washing suppliers before the returnable bottle trial begins.',
    'Check capacity, water use, food-safety records, delivery times, and service support.',
    'Share quotes and note which requirements each supplier can meet.'
  ]))
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
  await page.locator('.tags-field__input .v-field').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await screenshot.captureRegion('discussions/tags/tags_add_new', [
    '.discussion-form',
    '.v-overlay--active .v-list'
  ], {padding: 12, width: 1100, height: 1200});
});

test('tags_create_new', async ({ page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.locator('.tags-field__input .v-field').click()
  await page.locator('.tags-field__input input').fill('Supplier research')
  await screenshot.captureElement('discussions/tags/tags_create_new', '.discussion-form', {
    width: 1100,
    height: 1400,
    spotlight: {selector: '.discussion-form .tags-field__input', padding: 10, radius: 12}
  });
});

test('tags_created_new', async ({ page, manual: screenshot }) => {
  await openNewDiscussion(page);
  await page.locator('.tags-field__input .v-field').click()
  await page.locator('.tags-field__input input').fill('Supplier research')
  await page.locator('.tags-field__input input').press('Enter')
  await page.locator('.discussion-form__title-input input').click()
  await page.evaluate('document.activeElement.blur()')
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
  await page.locator('.tag-form__edit-tag').click()
  await expect(page.locator('.tags-modal__tag-name').first()).toBeVisible()
  await page.locator('.tags-modal__tag-name input').fill('Cafe network')
  await page.locator('.tag-color-button:nth-of-type(5)').click()
  await screenshot.captureElement('discussions/tags/tags_edit_name', '.tags-modal', {
    width: 1100,
    height: 1000
  });
});

test('tags_delete', async ({ page, manual: screenshot }) => {
  await openTagsManager(page);
  await page.locator('.tag-form__delete').click()
  await expect(page.locator('.confirm-modal').first()).toBeVisible()
  await screenshot.captureElement('discussions/tags/tags_delete', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});

test('tags_global_search', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1280, height: 1000 })
  await openGroup(page);
  await page.locator('.v-app-bar .navbar__search').click()
  await page.locator('.search-modal .v-select .v-field').click()
  await expect(page.locator('.v-menu.v-overlay--active .v-list').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.v-menu.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Oatmilk Cooperative')).classList.add('manual-parent-group')")
  await page.locator('.manual-parent-group').click()
  await expectLabel(page.locator('.search-modal'), 'Any tag')
  await page.evaluate("Array.from(document.querySelectorAll('.search-modal .v-select')).find(el => el.textContent.includes('Any tag')).setAttribute('data-manual-search-tags', '')")
  await page.locator('[data-manual-search-tags] .v-field').click()
  await expect(page.locator('.v-menu.v-overlay--active .v-list').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.v-menu.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Packaging')).classList.add('manual-packaging-tag')")
  await page.locator('.manual-packaging-tag').click()
  await expect(page.locator('.search-results-list .v-list-item').first()).toBeVisible()
  await page.locator('[data-manual-search-tags] .v-field').click()
  await expect(page.locator('.v-menu.v-overlay--active .v-list').first()).toBeVisible()
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

test('tags_thread_sidebar', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1440, height: 1100 })
  await openGroup(page);
  await page.evaluate("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')")
  await page.locator('.manual-topic').click()
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator('.new-comment .action-menu--btn').first()).toBeVisible()
  await page.evaluate("document.querySelector('.new-comment .action-menu--btn').scrollIntoView({block: 'center'})")
  await page.locator('.new-comment .action-menu--btn').click()
  await page.locator('.v-overlay--active .action-dock__button--edit_item_tags').click()
  await expect(page.locator('.topic-tags-dialog .topic-tags-picker__tag').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.topic-tags-dialog .topic-tags-picker__tag')).find(el => el.textContent.includes('Sustainability')).classList.add('manual-tag')")
  await page.locator('.manual-tag').click()
  await expectLabel(page.locator('.thread-tags'), 'Sustainability')
  await page.locator('.topic-tags-dialog .dismiss-modal-button').click()
  await page.evaluate('window.scrollTo(0, 0)')
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
  await page.evaluate("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')")
  await page.locator('.manual-topic').click()
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await page.locator('.topic-tags-menu__button').click()
  await expect(page.locator('.topic-tags-menu__popover').first()).toBeVisible()
  await screenshot.captureRegion('discussions/tags/tags_thread_edit', [
    '.context-panel',
    '.topic-tags-menu__popover'
  ], {padding: 16, width: 1280, height: 1000});
});
