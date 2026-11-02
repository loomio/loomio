import { test, expect } from '../fixtures.mjs';

for (const [state, params] of [
  ['open', ''], ['scheduled', '?scheduled=1'], ['closed', '?closed=1'],
  ['stv', '?poll_type=stv'],
  ['member', '?member=1&members_can_create_templates=1']
]) {
  test(`can_save_${state}_proposal_as_template_and_reuse_it`, async ({ lmo: page }) => {
    await page.loadPath(`polls/save_poll_as_template${params}`);
    await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--save_as_template');
    await page.expectNoElement('.action-dock__button--make_a_copy');
    await page.clickAndWait('.action-dock__button--save_as_template', '.poll-template-form__help');
    await page.refreshAndWait();
    await page.expectElement('.poll-template-form__help');
    await page.expectText('.poll-template-form__help', 'Templates let anyone in your group reuse');
    await page.expectAttribute('.poll-template-form__help a', 'href', '/en/user_manual/polls/poll_templates');
    await page.expectValue('.poll-template-form-fields__process-name input', 'Article proposal');
    await page.expectValue('.poll-template-form-fields__title input', 'Article proposal');
    await page.expectText('.poll-template-form .tags-field__input', 'Consent');
    await page.expectText('.poll-template-form .tags-field__input', 'Significant decisions');
    await page.expectText('.poll-template-form-fields__details', 'Proposed article changes');
    await page.expectText('.poll-template-form', 'I support these changes');
    await page.expectText('.poll-template-form', 'These changes need revision');
    await page.click('.topic-settings__comments label');
    await page.click('.topic-settings__attachments-admin-only label');
    await page.fillIn('.topic-settings__comment-length input', '120');
    await page.fillIn('.poll-template-form-fields__process-subtitle input', 'Reusable article consent process');
    await page.click('.poll-template-form__submit');
    await page.expectNoElement('.poll-template-form__submit', 8000);
    await page.expectText('.context-panel__heading', 'Article proposal');

    // Find the saved template in the group's New poll chooser, then use it.
    await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--save_as_template');
    const templateHref = await page.attribute('.action-dock__button--save_as_template', 'href');
    const pollId = new URL(templateHref, page.page.url()).searchParams.get('poll_id');
    const groupId = await page.execute(async pollId => {
      const response = await fetch(`/api/v1/polls/${pollId}`);
      return (await response.json()).polls[0].group_id;
    }, pollId);
    await page.goTo(`p/new?group_id=${groupId}`);
    if (state === 'stv') { await page.click('.poll-common-choose-template__poll'); }
    await page.expectText('.poll-common-templates-list', 'Article proposal');
    await page.click("//*[contains(@class, 'poll-common-templates-list')]//*[normalize-space(text())='Article proposal']");
    await page.expectElement('.poll-common-form__opens-immediately');
    await page.expectChecked('.poll-common-form__opens-immediately input');
    await page.expectText('.poll-common-form', 'I support these changes');
    await page.expectText('.poll-common-form', 'These changes need revision');
    await page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form .topic-settings__comments');
    await page.expectNotChecked('.poll-common-form .topic-settings__comments input');
    await page.expectChecked('.poll-common-form .topic-settings__attachments-admin-only input');
    await page.expectValue('.poll-common-form .topic-settings__comment-length input', '120');
    await page.click('.poll-common-form__submit');
    await page.expectNoElement('.poll-common-form__submit', 8000);
    await page.expectText('.topic-header .tags-display', 'Consent');
    await page.expectText('.topic-header .tags-display', 'Significant decisions');
    await page.click('.topic-sidebar .action-dock__button--thread_settings');
    await page.expectElement('.topic-arrangement-form .topic-settings__comments');
    await page.expectNoElement('.topic-arrangement-form .topic-settings__single-poll');
    await page.expectNotChecked('.topic-arrangement-form .topic-settings__comments input');
    await page.expectChecked('.topic-arrangement-form .topic-settings__attachments-admin-only input');
    await page.expectValue('.topic-arrangement-form .topic-settings__comment-length input', '120');
  });
}

test('member_without_template_permission_cannot_save_as_template', async ({ lmo: page }) => {
  await page.loadPath('polls/save_poll_as_template?member=1');
  await page.click('.poll-created .action-menu--btn');
  await page.expectNoElement('.action-dock__button--save_as_template');
  await page.expectNoElement('.action-dock__button--make_a_copy');
});

