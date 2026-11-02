const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'jumps_to_headings_in_context_polls_and_comments': async test => {
    const page = pageHelper(test);
    page.loadPath('setup_heading_navigation');
    page.resizeWindow(1440, 900);
    page.expectCount('.topic-sidebar .content-heading-link', 5);
    test.assert.textContains('.topic-sidebar', 'Agenda');
    test.assert.textContains('.topic-sidebar', 'Choices');
    test.assert.textContains('.topic-sidebar', 'Discussion notes');
    page.expectNoElement('.new-comment__body h1');
    await test.execute(() => {
      const links = [...document.querySelectorAll('.topic-sidebar .content-heading-link')];
      links.filter(link => link.textContent.trim() === 'Shared section').at(-1).click();
    });
    await test.pause(1000);
    await test.execute(() => ({
      isComment: !!document.activeElement.closest('.new-comment__body'),
      label: document.activeElement.textContent,
      top: document.activeElement.getBoundingClientRect().top
    }), [], result => {
      test.assert.equal(result.value.isComment, true);
      test.assert.equal(result.value.label, 'Shared section');
      test.assert.ok(Math.abs(result.value.top - 72) < 3, 'heading is below the toolbar');
    });

    // The drawer must close so a heading selected on a phone is visible.
    page.resizeWindow(390, 844);
    page.click('.v-app-bar button[title="Thread menu"]');
    await test.waitForElementVisible('.topic-sidebar .content-heading-link');
    await test.execute(() => document.querySelector('.topic-sidebar .content-heading-link').click());
    await test.waitForElementNotVisible('.topic-sidebar');
    await test.execute(() => document.activeElement.textContent, [], result => {
      test.assert.equal(result.value, 'Agenda');
    });

    page.resizeWindow(1440, 900);
    page.clickElement('.new-comment .action-dock__button--edit_comment');
    page.fillTextarea('.edit-comment-form .lmo-textarea textarea', '# Revised notes\n\n### New section\n\n## Shared section\n\nSupporting notes');
    page.click('.edit-comment-form .comment-form__submit-button');
    page.expectText('.topic-sidebar', 'Revised notes');
    page.expectText('.topic-sidebar', 'New section');
    page.expectCount('.topic-sidebar .content-heading-link', 6);
    await test.execute(() => performance.getEntriesByType('resource')
      .filter(entry => new URL(entry.name).pathname === '/api/v1/topic_items/headings').length, [], result => {
      test.assert.equal(result.value, 1, 'saved edits and loaded records do not refetch the outline');
    });
  }
};
