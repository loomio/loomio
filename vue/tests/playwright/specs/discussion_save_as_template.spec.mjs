import { test, expect } from '../fixtures.mjs';

for (const [role, params] of [['admin', ''], ['member', '?member=1&members_can_create_templates=1']]) {
  test(`can_save_discussion_as_template_and_reuse_it_as_${role}`, async ({ page }) => {
    await page.goto(`/dev/discussions/test_save_as_template${params}`)
    await page.locator('.topic-new-discussion .action-menu--btn').click()
    await expect(page.locator('.action-dock__button--make_a_copy')).toHaveCount(0)
    await page.locator('.action-dock__button--save_as_template').click()
    await page.reload()
    await expect(page.locator('.discussion-template-form')).toBeVisible()
    await expect(page.locator('.discussion-template-form-fields__process-name input')).toHaveValue('Monthly project review')
    await expect(page.locator('.discussion-template-form-fields__title input')).toHaveValue('Monthly project review')
    await expect(page.locator('.discussion-template-form .tags-field__input')).toContainText('Project review')
    await expect(page.locator('.discussion-template-form')).toContainText('What worked, and what should change next month?')
    await expect(page.locator('.discussion-template-form')).not.toContainText('Private review feedback')
    await expect(page.locator('.topic-settings__single-poll input')).not.toBeChecked()
    await page.locator('.topic-settings__single-poll label').click()
    await page.locator('.topic-settings__attachments-admin-only label').click()
    await page.locator('.topic-settings__comment-length input').fill('120')
    await page.locator('.discussion-template-form-fields__process-subtitle input').fill('Review the month and agree next steps')
    await page.locator('.discussion-template-form__submit').click()
    await expect(page.locator('.discussion-template-form__submit')).toHaveCount(0)
    await expect(page.locator('.context-panel__heading')).toContainText('Monthly project review')

    await page.locator('.topic-new-discussion .action-menu--btn').click()
    const templateHref = await page.locator('.action-dock__button--save_as_template').first().getAttribute('href');
    const discussionId = new URL(templateHref, page.url()).searchParams.get('discussion_id');
    const groupId = await page.evaluate(async discussionId => {
      const response = await fetch(`/api/v1/discussions/${discussionId}`);
      return (await response.json()).discussions[0].group_id;
    }, discussionId);
    await page.goto(`/discussion_templates?group_id=${groupId}`)
    await expect(page.locator('.discussion-templates-page')).toContainText('Monthly project review')
    await page.locator("//*[contains(@class, 'discussion-templates--template')]//*[normalize-space(text())='Monthly project review']").click()
    await expect(page.locator('.discussion-form__title-input input')).toHaveValue('Monthly project review')
    await expect(page.locator('.discussion-form .tags-field__input')).toContainText('Project review')
    await expect(page.locator('.discussion-form')).toContainText('What worked, and what should change next month?')
    await page.locator('.discussion-form__submit').click()
    await expect(page.locator('.discussion-form__submit')).toHaveCount(0)
    await expect(page.locator('.context-panel__heading')).toContainText('Monthly project review')
    await expect(page.locator('.topic-header .tags-display')).toContainText('Project review')
    await expect(page.locator('.topic-page')).not.toContainText('Private review feedback')
    await page.locator('.topic-sidebar .action-dock__button--thread_settings').click()
    await expect(page.locator('.topic-settings__single-poll input')).toBeChecked()
    await expect(page.locator('.topic-settings__attachments-admin-only input')).toBeChecked()
    await expect(page.locator('.topic-settings__comment-length input')).toHaveValue('120')
  });
}

test('member_without_template_permission_cannot_save_as_template', async ({ page }) => {
  await page.goto('/dev/discussions/test_save_as_template?member=1')
  await page.locator('.topic-new-discussion .action-menu--btn').click()
  await expect(page.locator('.action-dock__button--save_as_template')).toHaveCount(0)
});

