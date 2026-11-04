const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'tag_items_filter_the_thread_and_preserve_opening_tags': test => {
    const page = pageHelper(test);
    page.loadPath('setup_item_tags');
    page.resizeWindow(1440, 1100);
    page.expectText('.topic-header .tags-display', 'Governance');
    page.expectNoText('.topic-header .tags-display', 'Budget');
    page.expectText('.thread-tags', 'Budget');
    page.expectText('.topic-list', 'An unrelated contribution');
    page.click('.thread-tags .v-chip');
    page.expectElement('.tagged-items');
    page.expectText('.tag-filter-toolbar', 'Budget');
    page.waitFor('.tagged-items .new-comment .tag-color-dot');
    test.execute(() => ({
      icon: getComputedStyle(document.querySelector('.tag-filter-toolbar__icon')).color,
      tag: getComputedStyle(document.querySelector('.new-comment .tag-color-dot')).backgroundColor
    }), [], result => {
      test.assert.equal(result.value.icon, result.value.tag, 'Filter icon uses the selected tag color');
    });
    page.resizeWindow(1440, 600);
    page.execute('window.scrollTo(0, document.body.scrollHeight)');
    test.execute(() => {
      const bar = document.querySelector('.tag-filter-toolbar');
      return {position: getComputedStyle(bar).position, top: bar.getBoundingClientRect().top};
    }, [], result => {
      test.assert.equal(result.value.position, 'sticky');
      test.assert.ok(result.value.top >= 64 && result.value.top < 100, 'Filter toolbar stays below the app bar when scrolling');
    });
    page.resizeWindow(1440, 1100);
    page.expectText('.tagged-items', 'Insurance costs need a review');
    page.expectNoText('.tagged-items', 'An unrelated contribution');
    page.click('.tagged-items .item-tags .topic-tags-menu__button');
    page.expectElement('.topic-tags-menu__popover');
    page.click('.topic-tags-menu__popover .topic-tags-picker__tag');
    page.click('.topic-header h1');
    page.expectText('.topic-header .tags-display', 'Governance');
    page.click('.tag-filter-toolbar__close');
    page.expectNoElement('.tag-filter-toolbar');
    page.expectText('.topic-list', 'An unrelated contribution');
    page.refreshAndWait();
    page.expectText('.topic-header .tags-display', 'Governance');
    page.expectNoText('.thread-tags', 'Budget');
    test.end();
  },

  'new_tags_have_colors_without_reload_and_item_tags_share_the_metadata_row': test => {
    const page = pageHelper(test);
    page.loadPath('setup_item_tags');
    page.resizeWindow(1440, 1100);
    page.click('.topic-header .topic-tags-menu__button');
    page.expectText('.topic-tags-menu__popover', 'Unused');
    page.expectNoElement('.topic-tags-picker__all-tags');
    page.clickAndWait('.topic-tags-picker__new-tag', '.topic-tags-picker__new-tag-input input');
    page.fillInAndEnter('.topic-tags-picker__new-tag-input input', 'Planning');
    page.expectText('.topic-header .tags-display', 'Planning');
    page.expectText('.thread-tags', 'Planning');
    test.assert.elementsCount('.topic-header .tag-color-dot[style*="background-color"]', 2);
    page.click('.topic-header h1');

    page.execute("document.querySelector('.new-comment:has(.item-tags) .action-menu--btn').scrollIntoView({block: 'center'})");
    page.click('.new-comment:has(.item-tags) .action-menu--btn');
    page.expectText('.v-overlay--active .action-dock__button--edit_item_tags', 'Apply tags');
    page.click('.v-overlay--active .action-dock__button--edit_item_tags');
    page.expectText('.topic-tags-dialog .v-card-title', 'Apply tags');
    page.clickAndWait('.topic-tags-dialog .topic-tags-picker__new-tag', '.topic-tags-picker__new-tag-input input');
    page.fillInAndEnter('.topic-tags-picker__new-tag-input input', 'Follow up');
    page.expectText('.new-comment .topic-item__title .item-tags', 'Follow up');
    test.assert.elementsCount('.new-comment .item-tags .tag-color-dot[style*="background-color"]', 2);
    page.click('.topic-tags-dialog .dismiss-modal-button');
    page.click('.topic-header h1');

    page.expectText('.poll-created .poll-common-details-panel__started-by .item-tags', 'Decision');
    page.expectText('.outcome-created .topic-item__title .item-tags', 'Resolution');
    test.execute(() => {
      const headline = document.querySelector('.new-comment .topic-item__title');
      const tags = headline.querySelector('.item-tags');
      const untagged = document.querySelector('.new-comment:not(:has(.item-tags)) .topic-item__title');
      return {height: headline.getBoundingClientRect().height, heightUntagged: untagged.getBoundingClientRect().height,
        right: Math.abs(headline.getBoundingClientRect().right - tags.getBoundingClientRect().right),
        sameRow: Math.abs(headline.querySelector('.actor-link').getBoundingClientRect().top - tags.getBoundingClientRect().top) < 12};
    }, [], result => {
      test.assert.ok(result.value.right < 2, 'Comment tags align with the right edge of the headline');
      test.assert.ok(result.value.sameRow, 'Comment tags share the author and timestamp row');
      test.assert.ok(Math.abs(result.value.height - result.value.heightUntagged) < 1, 'Tags do not increase the headline height');
    });
    test.saveScreenshot('tests/screenshots/item_tags/desktop.png');
    page.resizeWindow(390, 844);
    test.execute(() => document.documentElement.scrollWidth <= window.innerWidth, [], result => {
      test.assert.ok(result.value, 'Tag rows fit the mobile viewport');
    });
    test.saveScreenshot('tests/screenshots/item_tags/mobile.png');
    test.end();
  }
};
