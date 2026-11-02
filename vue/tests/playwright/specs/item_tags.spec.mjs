import { test, expect } from '../fixtures.mjs';

test('tag_items_filter_the_thread_and_preserve_opening_tags', async ({ lmo: page }) => {
  await page.loadPath('setup_item_tags');
  await page.resizeWindow(1440, 1100);
  await page.expectText('.topic-header .tags-display', 'Governance');
  await page.expectNoText('.topic-header .tags-display', 'Budget');
  await page.expectText('.thread-tags', 'Budget');
  await page.expectText('.topic-list', 'An unrelated contribution');
  await page.click('.thread-tags .v-chip');
  await page.expectElement('.tagged-items');
  await page.expectText('.tag-filter-toolbar', 'Budget');
  await page.waitFor('.tagged-items .new-comment .tag-color-dot');
  const colors = await page.execute(() => ({
    icon: getComputedStyle(document.querySelector('.tag-filter-toolbar__icon')).color,
    tag: getComputedStyle(document.querySelector('.new-comment .tag-color-dot')).backgroundColor
  }));
  expect(colors.icon, 'Filter icon uses the selected tag color').toBe(colors.tag);
  await page.resizeWindow(1440, 600);
  await page.execute('window.scrollTo(0, document.body.scrollHeight)');
  const bar = await page.execute(() => {
    const bar = document.querySelector('.tag-filter-toolbar');
    return {position: getComputedStyle(bar).position, top: bar.getBoundingClientRect().top};
  });
  expect(bar.position).toBe('sticky');
  expect(bar.top >= 64 && bar.top < 100, 'Filter toolbar stays below the app bar when scrolling').toBe(true);
  await page.resizeWindow(1440, 1100);
  await page.expectText('.tagged-items', 'Insurance costs need a review');
  await page.expectNoText('.tagged-items', 'An unrelated contribution');
  await page.click('.tagged-items .item-tags .topic-tags-menu__button');
  await page.expectElement('.topic-tags-menu__popover');
  await page.click('.topic-tags-menu__popover .topic-tags-picker__tag');
  await page.click('.topic-header h1');
  await page.expectText('.topic-header .tags-display', 'Governance');
  await page.click('.tag-filter-toolbar__close');
  await page.expectNoElement('.tag-filter-toolbar');
  await page.expectText('.topic-list', 'An unrelated contribution');
  await page.refreshAndWait();
  await page.expectText('.topic-header .tags-display', 'Governance');
  await page.expectNoText('.thread-tags', 'Budget');
});

test('new_tags_have_colors_without_reload_and_item_tags_share_the_metadata_row', async ({ lmo: page }) => {
  await page.loadPath('setup_item_tags');
  await page.resizeWindow(1440, 1100);
  await page.click('.topic-header .topic-tags-menu__button');
  await page.expectText('.topic-tags-menu__popover', 'Unused');
  await page.expectNoElement('.topic-tags-picker__all-tags');
  await page.clickAndWait('.topic-tags-picker__new-tag', '.topic-tags-picker__new-tag-input input');
  await page.fillInAndEnter('.topic-tags-picker__new-tag-input input', 'Planning');
  await page.expectText('.topic-header .tags-display', 'Planning');
  await page.expectText('.thread-tags', 'Planning');
  await page.expectCount('.topic-header .tag-color-dot[style*="background-color"]', 2);
  await page.click('.topic-header h1');

  await page.execute("document.querySelector('.new-comment:has(.item-tags) .action-menu--btn').scrollIntoView({block: 'center'})");
  await page.click('.new-comment:has(.item-tags) .action-menu--btn');
  await page.expectText('.v-overlay--active .action-dock__button--edit_item_tags', 'Apply tags');
  await page.click('.v-overlay--active .action-dock__button--edit_item_tags');
  await page.expectText('.topic-tags-dialog .v-card-title', 'Apply tags');
  await page.clickAndWait('.topic-tags-dialog .topic-tags-picker__new-tag', '.topic-tags-picker__new-tag-input input');
  await page.fillInAndEnter('.topic-tags-picker__new-tag-input input', 'Follow up');
  await page.expectText('.new-comment .topic-item__title .item-tags', 'Follow up');
  await page.expectCount('.new-comment .item-tags .tag-color-dot[style*="background-color"]', 2);
  await page.click('.topic-tags-dialog .dismiss-modal-button');
  await page.click('.topic-header h1');

  await page.expectText('.poll-created .poll-common-details-panel__started-by .item-tags', 'Decision');
  await page.expectText('.outcome-created .topic-item__title .item-tags', 'Resolution');
  const layout = await page.execute(() => {
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
  await page.resizeWindow(390, 844);
  expect(await page.execute(() => document.documentElement.scrollWidth <= window.innerWidth),
    'Tag rows fit the mobile viewport').toBe(true);
});
