import { test, expect } from '../fixtures.mjs';

test('tag_items_filter_the_thread_and_preserve_opening_tags', async ({ page }) => {
  await page.goto('/dev/setup_item_tags')
  await page.setViewportSize({ width: 1440, height: 1100 })
  await expect(page.locator('.topic-header .tags-display')).toContainText('Governance')
  await expect(page.locator('.topic-header .tags-display')).not.toContainText('Budget')
  await expect(page.locator('.thread-tags')).toContainText('Budget')
  await expect(page.locator('.topic-list')).toContainText('An unrelated contribution')
  await page.click('.thread-tags .v-chip')
  await expect(page.locator('.tagged-items')).toBeVisible()
  await expect(page.locator('.tag-filter-toolbar')).toContainText('Budget')
  await expect(page.locator('.tagged-items .new-comment .tag-color-dot')).toBeVisible()
  const colors = await page.evaluate(() => ({
    icon: getComputedStyle(document.querySelector('.tag-filter-toolbar__icon')).color,
    tag: getComputedStyle(document.querySelector('.new-comment .tag-color-dot')).backgroundColor
  }));
  expect(colors.icon, 'Filter icon uses the selected tag color').toBe(colors.tag);
  await page.setViewportSize({ width: 1440, height: 600 })
  await page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
  const bar = await page.evaluate(() => {
    const bar = document.querySelector('.tag-filter-toolbar');
    return {position: getComputedStyle(bar).position, top: bar.getBoundingClientRect().top};
  });
  expect(bar.position).toBe('sticky');
  expect(bar.top >= 64 && bar.top < 100, 'Filter toolbar stays below the app bar when scrolling').toBe(true);
  await page.setViewportSize({ width: 1440, height: 1100 })
  await expect(page.locator('.tagged-items')).toContainText('Insurance costs need a review')
  await expect(page.locator('.tagged-items')).not.toContainText('An unrelated contribution')
  await page.click('.tagged-items .item-tags .topic-tags-menu__button')
  await expect(page.locator('.topic-tags-menu__popover')).toBeVisible()
  await page.click('.topic-tags-menu__popover .topic-tags-picker__tag')
  await page.click('.topic-header h1')
  await expect(page.locator('.topic-header .tags-display')).toContainText('Governance')
  await page.click('.tag-filter-toolbar__close')
  await expect(page.locator('.tag-filter-toolbar')).toHaveCount(0)
  await expect(page.locator('.topic-list')).toContainText('An unrelated contribution')
  await page.reload()
  await expect(page.locator('.topic-header .tags-display')).toContainText('Governance')
  await expect(page.locator('.thread-tags')).not.toContainText('Budget')
});

test('new_tags_have_colors_without_reload_and_item_tags_share_the_metadata_row', async ({ page }) => {
  await page.goto('/dev/setup_item_tags')
  await page.setViewportSize({ width: 1440, height: 1100 })
  await page.click('.topic-header .topic-tags-menu__button')
  await expect(page.locator('.topic-tags-menu__popover')).toContainText('Unused')
  await expect(page.locator('.topic-tags-picker__all-tags')).toHaveCount(0)
  await page.click('.topic-tags-picker__new-tag')
  await page.fill('.topic-tags-picker__new-tag-input input', 'Planning')
  await page.press('.topic-tags-picker__new-tag-input input', 'Enter')
  await expect(page.locator('.topic-header .tags-display')).toContainText('Planning')
  await expect(page.locator('.thread-tags')).toContainText('Planning')
  await expect(page.locator('.topic-header .tag-color-dot[style*="background-color"]')).toHaveCount(2)
  await page.click('.topic-header h1')

  await page.click('.new-comment:has(.item-tags) .action-menu--btn')
  await expect(page.locator('.v-overlay--active .action-dock__button--edit_item_tags')).toContainText('Apply tags')
  await page.click('.v-overlay--active .action-dock__button--edit_item_tags')
  await expect(page.locator('.topic-tags-dialog .v-card-title')).toContainText('Apply tags')
  await page.click('.topic-tags-dialog .topic-tags-picker__new-tag')
  await page.fill('.topic-tags-picker__new-tag-input input', 'Follow up')
  await page.press('.topic-tags-picker__new-tag-input input', 'Enter')
  await expect(page.locator('.new-comment .topic-item__title .item-tags')).toContainText('Follow up')
  await expect(page.locator('.new-comment .item-tags .tag-color-dot[style*="background-color"]')).toHaveCount(2)
  await page.click('.topic-tags-dialog .dismiss-modal-button')
  await page.click('.topic-header h1')

  await expect(page.locator('.poll-created .poll-common-details-panel__started-by .item-tags')).toContainText('Decision')
  await expect(page.locator('.outcome-created .topic-item__title .item-tags')).toContainText('Resolution')
  const layout = await page.evaluate(() => {
    const headline = document.querySelector('.new-comment .topic-item__title');
    const tags = headline.querySelector('.item-tags');
    const untagged = document.querySelector('.new-comment:not(:has(.item-tags)) .topic-item__title');
    return {height: headline.getBoundingClientRect().height, heightUntagged: untagged.getBoundingClientRect().height,
      right: Math.abs(headline.getBoundingClientRect().right - tags.getBoundingClientRect().right),
      sameRow: Math.abs(headline.querySelector('.actor-link').getBoundingClientRect().top - tags.getBoundingClientRect().top) < 12};
  });
  expect(layout.right < 2, 'Comment tags align with the right edge of the headline').toBe(true);
  expect(layout.sameRow, 'Comment tags share the author and timestamp row').toBe(true);
  expect(Math.abs(layout.height - layout.heightUntagged) < 1, 'Tags do not increase the headline height').toBe(true);
  await page.setViewportSize({ width: 390, height: 844 })
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth),
    'Tag rows fit the mobile viewport').toBe(true);
});
