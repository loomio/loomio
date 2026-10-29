const pageHelper = require('../helpers/pageHelper');

const tests = {};
for (const [role, params] of [['admin', ''], ['member', '?member=1&members_can_create_templates=1']]) {
  tests[`can_save_discussion_as_template_and_reuse_it_as_${role}`] = test => {
    const page = pageHelper(test);
    page.loadPath(`discussions/test_save_as_template${params}`);
    page.clickAndWait('.topic-new-discussion .action-menu--btn', '.action-dock__button--save_as_template');
    page.expectNoElement('.action-dock__button--make_a_copy');
    page.clickAndWait('.action-dock__button--save_as_template', '.discussion-template-form');
    page.refreshAndWait();
    page.expectElement('.discussion-template-form');
    page.expectValue('.discussion-template-form-fields__process-name input', 'Monthly project review');
    page.expectValue('.discussion-template-form-fields__title input', 'Monthly project review');
    page.expectText('.discussion-template-form .tags-field__input', 'Project review');
    page.expectText('.discussion-template-form', 'What worked, and what should change next month?');
    page.expectNoText('.discussion-template-form', 'Private review feedback');
    page.fillIn('.discussion-template-form-fields__process-subtitle input', 'Review the month and agree next steps');
    page.click('.discussion-template-form__submit');
    page.expectNoElement('.discussion-template-form__submit', 8000);
    page.expectText('.context-panel__heading', 'Monthly project review');

    page.clickAndWait('.topic-new-discussion .action-menu--btn', '.action-dock__button--save_as_template');
    test.getAttribute('.action-dock__button--save_as_template', 'href', result => {
      const discussionId = new URL(result.value).searchParams.get('discussion_id');
      test.executeAsync(function(discussionId, done) {
        fetch(`/api/v1/discussions/${discussionId}`).then(response => response.json()).then(data => done(data.discussions[0].group_id));
      }, [discussionId], result => page.goTo(`discussion_templates?group_id=${result.value}`));
    });
    page.expectText('.discussion-templates-page', 'Monthly project review');
    test.useXpath();
    test.click("//*[contains(@class, 'discussion-templates--template')]//*[normalize-space(text())='Monthly project review']");
    test.useCss();
    page.expectValue('.discussion-form__title-input input', 'Monthly project review');
    page.expectText('.discussion-form .tags-field__input', 'Project review');
    page.expectText('.discussion-form', 'What worked, and what should change next month?');
    page.click('.discussion-form__submit');
    page.expectNoElement('.discussion-form__submit', 8000);
    page.expectText('.context-panel__heading', 'Monthly project review');
    page.expectText('.topic-header .tags-display', 'Project review');
    page.expectNoText('.topic-page', 'Private review feedback');
  };
}

tests.member_without_template_permission_cannot_save_as_template = test => {
  const page = pageHelper(test);
  page.loadPath('discussions/test_save_as_template?member=1');
  page.click('.topic-new-discussion .action-menu--btn');
  page.expectNoElement('.action-dock__button--save_as_template');
};

module.exports = tests;
