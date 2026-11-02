import { test, expect } from '../fixtures.mjs';

for (const [role, params] of [['admin', ''], ['member', '?member=1&members_can_create_templates=1']]) {
  test(`can_save_discussion_as_template_and_reuse_it_as_${role}`, async ({ lmo: page }) => {
    await page.loadPath(`discussions/test_save_as_template${params}`);
    await page.clickAndWait('.topic-new-discussion .action-menu--btn', '.action-dock__button--save_as_template');
    await page.expectNoElement('.action-dock__button--make_a_copy');
    await page.clickAndWait('.action-dock__button--save_as_template', '.discussion-template-form');
    await page.refreshAndWait();
    await page.expectElement('.discussion-template-form');
    await page.expectValue('.discussion-template-form-fields__process-name input', 'Monthly project review');
    await page.expectValue('.discussion-template-form-fields__title input', 'Monthly project review');
    await page.expectText('.discussion-template-form .tags-field__input', 'Project review');
    await page.expectText('.discussion-template-form', 'What worked, and what should change next month?');
    await page.expectNoText('.discussion-template-form', 'Private review feedback');
    await page.expectNotChecked('.topic-settings__single-poll input');
    await page.click('.topic-settings__single-poll label');
    await page.click('.topic-settings__attachments-admin-only label');
    await page.fillIn('.topic-settings__comment-length input', '120');
    await page.fillIn('.discussion-template-form-fields__process-subtitle input', 'Review the month and agree next steps');
    await page.click('.discussion-template-form__submit');
    await page.expectNoElement('.discussion-template-form__submit', 8000);
    await page.expectText('.context-panel__heading', 'Monthly project review');

    await page.clickAndWait('.topic-new-discussion .action-menu--btn', '.action-dock__button--save_as_template');
    const templateHref = await page.attribute('.action-dock__button--save_as_template', 'href');
    const discussionId = new URL(templateHref, page.page.url()).searchParams.get('discussion_id');
    const groupId = await page.execute(async discussionId => {
      const response = await fetch(`/api/v1/discussions/${discussionId}`);
      return (await response.json()).discussions[0].group_id;
    }, discussionId);
    await page.goTo(`discussion_templates?group_id=${groupId}`);
    await page.expectText('.discussion-templates-page', 'Monthly project review');
    await page.click("//*[contains(@class, 'discussion-templates--template')]//*[normalize-space(text())='Monthly project review']");
    await page.expectValue('.discussion-form__title-input input', 'Monthly project review');
    await page.expectText('.discussion-form .tags-field__input', 'Project review');
    await page.expectText('.discussion-form', 'What worked, and what should change next month?');
    await page.click('.discussion-form__submit');
    await page.expectNoElement('.discussion-form__submit', 8000);
    await page.expectText('.context-panel__heading', 'Monthly project review');
    await page.expectText('.topic-header .tags-display', 'Project review');
    await page.expectNoText('.topic-page', 'Private review feedback');
    await page.click('.topic-sidebar .action-dock__button--thread_settings');
    await page.expectChecked('.topic-settings__single-poll input');
    await page.expectChecked('.topic-settings__attachments-admin-only input');
    await page.expectValue('.topic-settings__comment-length input', '120');
  });
}

test('member_without_template_permission_cannot_save_as_template', async ({ lmo: page }) => {
  await page.loadPath('discussions/test_save_as_template?member=1');
  await page.click('.topic-new-discussion .action-menu--btn');
  await page.expectNoElement('.action-dock__button--save_as_template');
});

