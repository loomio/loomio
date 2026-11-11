import { test, expect } from '../fixtures.mjs';
import { box } from '../helpers/layout.mjs';
import { comment, itemAction, thread } from '../helpers/threads.mjs';

const headerTags = page => page.locator('.topic-header .tags-display');
const threadTags = page => page.locator('.thread-tags');
const tagged = page => comment(page, 'Insurance costs need a review');
const untagged = page => comment(page, 'An unrelated contribution');
const closeMenus = page => page.locator('.topic-header h1').click();

async function addTag(page, name) {
  await page.locator('.topic-tags-picker__new-tag').click();
  await page.locator('.topic-tags-picker__new-tag-input input').fill(name);
  await page.locator('.topic-tags-picker__new-tag-input input').press('Enter');
}

test.beforeEach(async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 1100 });
  await page.goto('/dev/setup_item_tags');
});

test('item tags filter the thread and keep the thread\'s own tags', async ({ page }) => {
  await expect(headerTags(page)).toContainText('Governance');
  await expect(headerTags(page)).not.toContainText('Budget');
  await expect(threadTags(page)).toContainText('Budget');
  await expect(thread(page)).toContainText('An unrelated contribution');

  await threadTags(page).locator('.v-chip', { hasText: 'Budget' }).click();
  const toolbar = page.locator('.tag-filter-toolbar');
  const items = page.locator('.tagged-items');
  await expect(toolbar).toContainText('Budget');
  await expect(items).toContainText('Insurance costs need a review');
  await expect(items).not.toContainText('An unrelated contribution');

  // The filter icon takes the tag's colour.
  const dot = items.locator('.new-comment .tag-color-dot');
  const tagColor = await dot.evaluate(element => getComputedStyle(element).backgroundColor);
  await expect(toolbar.locator('.tag-filter-toolbar__icon')).toHaveCSS('color', tagColor);

  // The toolbar sticks below the app bar while scrolling.
  await page.setViewportSize({ width: 1440, height: 600 });
  await expect(toolbar).toHaveCSS('position', 'sticky');
  await page.mouse.wheel(0, 5000);
  await expect.poll(async () => (await box(toolbar)).y).toBeGreaterThanOrEqual(64);
  expect((await box(toolbar)).y).toBeLessThan(100);
  await page.setViewportSize({ width: 1440, height: 1100 });

  // Removing the filtered tag from an item leaves the thread's tags alone.
  await items.locator('.item-tags .topic-tags-menu__button').click();
  await page.locator('.topic-tags-menu__popover .topic-tags-picker__tag', { hasText: 'Budget' }).click();
  await closeMenus(page);
  await expect(headerTags(page)).toContainText('Governance');
  await page.locator('.tag-filter-toolbar__close').click();
  await expect(toolbar).toHaveCount(0);
  await expect(thread(page)).toContainText('An unrelated contribution');
  await page.reload();
  await expect(headerTags(page)).toContainText('Governance');
  await expect(threadTags(page)).not.toContainText('Budget');
});

test('new tags get colours at once, and item tags share the item\'s metadata row', async ({ page }) => {
  const coloredDots = scope => scope.locator('.tag-color-dot[style*="background-color"]');

  await page.locator('.topic-header .topic-tags-menu__button').click();
  await expect(page.locator('.topic-tags-menu__popover')).toContainText('Unused');
  await expect(page.locator('.topic-tags-picker__all-tags')).toHaveCount(0);
  await addTag(page, 'Planning');
  await expect(headerTags(page)).toContainText('Planning');
  await expect(threadTags(page)).toContainText('Planning');
  await expect(coloredDots(page.locator('.topic-header'))).toHaveCount(2);
  await closeMenus(page);

  await itemAction(page, tagged(page), 'edit_item_tags');
  const dialog = page.locator('.topic-tags-dialog');
  await expect(dialog.locator('.v-card-title')).toContainText('Apply tags');
  await addTag(page, 'Follow up');
  const itemTags = tagged(page).locator('.topic-item__title .item-tags');
  await expect(itemTags).toContainText('Follow up');
  await expect(coloredDots(itemTags)).toHaveCount(2);
  await dialog.locator('.dismiss-modal-button').click();
  await closeMenus(page);

  await expect(page.locator('.poll-created .poll-common-details-panel__started-by .item-tags')).toContainText('Decision');
  await expect(page.locator('.outcome-created .topic-item__title .item-tags')).toContainText('Resolution');

  // Tags sit at the right end of the author and time row, without making it taller.
  const headline = await box(tagged(page).locator('.topic-item__title'));
  const tags = await box(itemTags);
  // The author and time links share the row; either will do.
  const author = await box(tagged(page).locator('.topic-item__title .actor-link').first());
  const plainHeadline = await box(untagged(page).locator('.topic-item__title'));
  expect(Math.abs(headline.right - tags.right)).toBeLessThan(2);
  expect(Math.abs(author.y - tags.y)).toBeLessThan(12);
  expect(Math.abs(headline.height - plainHeadline.height)).toBeLessThan(1);

  // Vuetify 4.3.2 keeps the desktop drawer offsets for a frame after the
  // drawers switch to mobile, so wait for the layout to settle.
  await page.setViewportSize({ width: 390, height: 844 });
  await expect.poll(
    () => page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth),
    {message: 'tag rows fit a phone screen'}
  ).toBeLessThanOrEqual(0);
});
