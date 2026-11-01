const pageHelper = require('../helpers/pageHelper');

const tests = {};

for (const [state, params] of [
  ['open', ''], ['scheduled', '?scheduled=1'], ['closed', '?closed=1'],
  ['stv', '?poll_type=stv'],
  ['member', '?member=1&members_can_create_templates=1']
]) {
  tests[`can_save_${state}_proposal_as_template_and_reuse_it`] = test => {
    const page = pageHelper(test);
    page.loadPath(`polls/save_poll_as_template${params}`);
    page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--save_as_template');
    page.expectNoElement('.action-dock__button--make_a_copy');
    page.clickAndWait('.action-dock__button--save_as_template', '.poll-template-form__help');
    page.refreshAndWait();
    page.expectElement('.poll-template-form__help');
    page.expectText('.poll-template-form__help', 'Templates let anyone in your group reuse');
    test.assert.attributeContains('.poll-template-form__help a', 'href', '/en/user_manual/polls/poll_templates');
    page.expectValue('.poll-template-form-fields__process-name input', 'Article proposal');
    page.expectValue('.poll-template-form-fields__title input', 'Article proposal');
    page.expectText('.poll-template-form .tags-field__input', 'Consent');
    page.expectText('.poll-template-form .tags-field__input', 'Significant decisions');
    page.expectText('.poll-template-form-fields__details', 'Proposed article changes');
    page.expectText('.poll-template-form', 'I support these changes');
    page.expectText('.poll-template-form', 'These changes need revision');
    page.click('.topic-settings__comments label');
    page.click('.topic-settings__attachments-admin-only label');
    page.fillIn('.topic-settings__comment-length input', '120');
    page.fillIn('.poll-template-form-fields__process-subtitle input', 'Reusable article consent process');
    page.click('.poll-template-form__submit');
    page.expectNoElement('.poll-template-form__submit', 8000);
    page.expectText('.context-panel__heading', 'Article proposal');

    // Find the saved template in the group's New poll chooser, then use it.
    page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--save_as_template');
    test.getAttribute('.action-dock__button--save_as_template', 'href', result => {
      const pollId = new URL(result.value).searchParams.get('poll_id');
      test.executeAsync(function(pollId, done) {
        fetch(`/api/v1/polls/${pollId}`).then(response => response.json()).then(data => done(data.polls[0].group_id));
      }, [pollId], result => page.goTo(`p/new?group_id=${result.value}`));
    });
    if (state === 'stv') { page.click('.poll-common-choose-template__poll'); }
    page.expectText('.poll-common-templates-list', 'Article proposal');
    test.useXpath();
    test.click("//*[contains(@class, 'poll-common-templates-list')]//*[normalize-space(text())='Article proposal']");
    test.useCss();
    page.expectElement('.poll-common-form__opens-immediately');
    test.assert.selected('.poll-common-form__opens-immediately input');
    page.expectText('.poll-common-form', 'I support these changes');
    page.expectText('.poll-common-form', 'These changes need revision');
    page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form .topic-settings__comments');
    test.assert.not.selected('.poll-common-form .topic-settings__comments input');
    test.assert.selected('.poll-common-form .topic-settings__attachments-admin-only input');
    page.expectValue('.poll-common-form .topic-settings__comment-length input', '120');
    page.click('.poll-common-form__submit');
    page.expectNoElement('.poll-common-form__submit', 8000);
    page.expectText('.topic-header .tags-display', 'Consent');
    page.expectText('.topic-header .tags-display', 'Significant decisions');
    page.click('.topic-sidebar .action-dock__button--thread_settings');
    page.expectElement('.topic-arrangement-form .topic-settings__comments');
    page.expectNoElement('.topic-arrangement-form .topic-settings__single-poll');
    test.assert.not.selected('.topic-arrangement-form .topic-settings__comments input');
    test.assert.selected('.topic-arrangement-form .topic-settings__attachments-admin-only input');
    page.expectValue('.topic-arrangement-form .topic-settings__comment-length input', '120');
  };
}

tests.member_without_template_permission_cannot_save_as_template = test => {
  const page = pageHelper(test);
  page.loadPath('polls/save_poll_as_template?member=1');
  page.click('.poll-created .action-menu--btn');
  page.expectNoElement('.action-dock__button--save_as_template');
  page.expectNoElement('.action-dock__button--make_a_copy');
};

module.exports = tests;
