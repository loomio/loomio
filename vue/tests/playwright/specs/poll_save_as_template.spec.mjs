import { test, expect } from '../fixtures.mjs';

for (const [state, params] of [
  ['open', ''], ['scheduled', '?scheduled=1'], ['closed', '?closed=1'],
  ['stv', '?poll_type=stv'],
  ['member', '?member=1&members_can_create_templates=1']
]) {
  test(`can_save_${state}_proposal_as_template_and_reuse_it`, async ({ page }) => {
    await page.goto(`/dev/polls/save_poll_as_template${params}`)
    await page.locator('.poll-created .action-menu--btn').click()
    await expect(page.locator('.action-dock__button--make_a_copy')).toHaveCount(0)
    await page.locator('.action-dock__button--save_as_template').click()
    await page.reload()
    await expect(page.locator('.poll-template-form__help')).toBeVisible()
    await expect(page.locator('.poll-template-form__help')).toContainText('Templates let anyone in your group reuse')
    await expect(page.locator('.poll-template-form__help a')).toHaveAttribute('href', /\/en\/user_manual\/polls\/poll_templates/)
    await expect(page.locator('.poll-template-form-fields__process-name input')).toHaveValue('Article proposal')
    await expect(page.locator('.poll-template-form-fields__title input')).toHaveValue('Article proposal')
    await expect(page.locator('.poll-template-form .tags-field__input')).toContainText('Consent')
    await expect(page.locator('.poll-template-form .tags-field__input')).toContainText('Significant decisions')
    await expect(page.locator('.poll-template-form-fields__details')).toContainText('Proposed article changes')
    await expect(page.locator('.poll-template-form')).toContainText('I support these changes')
    await expect(page.locator('.poll-template-form')).toContainText('These changes need revision')
    await page.locator('.topic-settings__comments label').click()
    await page.locator('.topic-settings__attachments-admin-only label').click()
    await page.locator('.topic-settings__comment-length input').fill('120')
    await page.locator('.poll-template-form-fields__process-subtitle input').fill('Reusable article consent process')
    await page.locator('.poll-template-form__submit').click()
    await expect(page.locator('.poll-template-form__submit')).toHaveCount(0)
    await expect(page.locator('.context-panel__heading')).toContainText('Article proposal')

    // Find the saved template in the group's New poll chooser, then use it.
    await page.locator('.poll-created .action-menu--btn').click()
    const templateHref = await page.locator('.action-dock__button--save_as_template').first().getAttribute('href');
    const pollId = new URL(templateHref, page.url()).searchParams.get('poll_id');
    const groupId = await page.evaluate(async pollId => {
      const response = await fetch(`/api/v1/polls/${pollId}`);
      return (await response.json()).polls[0].group_id;
    }, pollId);
    await page.goto(`/p/new?group_id=${groupId}`)
    if (state === 'stv') { await page.locator('.poll-common-choose-template__poll').click(); }
    await expect(page.locator('.poll-common-templates-list')).toContainText('Article proposal')
    await page.locator("//*[contains(@class, 'poll-common-templates-list')]//*[normalize-space(text())='Article proposal']").click()
    await expect(page.locator('.poll-common-form__opens-immediately')).toBeVisible()
    await expect(page.locator('.poll-common-form__opens-immediately input')).toBeChecked()
    await expect(page.locator('.poll-common-form')).toContainText('I support these changes')
    await expect(page.locator('.poll-common-form')).toContainText('These changes need revision')
    await page.locator('.poll-common-form__more-settings').click()
    await expect(page.locator('.poll-common-form .topic-settings__comments input')).not.toBeChecked()
    await expect(page.locator('.poll-common-form .topic-settings__attachments-admin-only input')).toBeChecked()
    await expect(page.locator('.poll-common-form .topic-settings__comment-length input')).toHaveValue('120')
    await page.locator('.poll-common-form__submit').click()
    await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
    await expect(page.locator('.topic-header .tags-display')).toContainText('Consent')
    await expect(page.locator('.topic-header .tags-display')).toContainText('Significant decisions')
    await page.locator('.topic-sidebar .action-dock__button--thread_settings').click()
    await expect(page.locator('.topic-arrangement-form .topic-settings__comments')).toBeVisible()
    await expect(page.locator('.topic-arrangement-form .topic-settings__single-poll')).toHaveCount(0)
    await expect(page.locator('.topic-arrangement-form .topic-settings__comments input')).not.toBeChecked()
    await expect(page.locator('.topic-arrangement-form .topic-settings__attachments-admin-only input')).toBeChecked()
    await expect(page.locator('.topic-arrangement-form .topic-settings__comment-length input')).toHaveValue('120')
  });
}

test('member_without_template_permission_cannot_save_as_template', async ({ page }) => {
  await page.goto('/dev/polls/save_poll_as_template?member=1')
  await page.locator('.poll-created .action-menu--btn').click()
  await expect(page.locator('.action-dock__button--save_as_template')).toHaveCount(0)
  await expect(page.locator('.action-dock__button--make_a_copy')).toHaveCount(0)
});

