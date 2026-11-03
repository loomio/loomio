import { test, expect } from '../fixtures.mjs';
import { itemAction } from '../helpers/threads.mjs';

const thread = page => page.locator('.topic-new-discussion');

for (const [role, params] of [['a group admin', ''], ['a member allowed to', '?member=1&members_can_create_templates=1']]) {
  test(`${role} saves a thread as a template and starts a thread from it`, async ({ page }) => {
    await page.goto(`/dev/discussions/test_save_as_template${params}`);
    await itemAction(page, thread(page), 'save_as_template');
    await expect(page.locator('.v-overlay--active .action-dock__button--make_a_copy')).toHaveCount(0);
    await expect(page).toHaveURL(/\/discussion_templates\/new\?discussion_id=\d+/);
    const discussionId = new URL(page.url()).searchParams.get('discussion_id');
    // The form loads its copy from the URL alone.
    await page.reload();

    const form = page.locator('.discussion-template-form');
    await expect(form.locator('.discussion-template-form-fields__process-name input')).toHaveValue('Monthly project review');
    await expect(form.locator('.discussion-template-form-fields__title input')).toHaveValue('Monthly project review');
    await expect(form.locator('.tags-field__input')).toContainText('Project review');
    await expect(form).toContainText('What worked, and what should change next month?');
    await expect(form).not.toContainText('Private review feedback');
    await expect(form.locator('.topic-settings__single-poll input')).not.toBeChecked();
    await form.locator('.topic-settings__single-poll input').check();
    await form.locator('.topic-settings__attachments-admin-only input').check();
    await form.locator('.topic-settings__comment-length input').fill('120');
    await form.locator('.discussion-template-form-fields__process-subtitle input').fill('Review the month and agree next steps');
    await form.locator('.discussion-template-form__submit').click();
    await expect(form).toHaveCount(0);
    await expect(page.locator('.context-panel__heading')).toContainText('Monthly project review');

    const response = await page.request.get(`/api/v1/discussions/${discussionId}`);
    const groupId = (await response.json()).discussions[0].group_id;
    await page.goto(`/discussion_templates?group_id=${groupId}`);
    await page.locator('.discussion-templates--template', { hasText: 'Monthly project review' }).click();

    const newThread = page.locator('.discussion-form');
    await expect(newThread.locator('.discussion-form__title-input input')).toHaveValue('Monthly project review');
    await expect(newThread.locator('.tags-field__input')).toContainText('Project review');
    await expect(newThread).toContainText('What worked, and what should change next month?');
    await newThread.locator('.discussion-form__submit').click();
    await expect(newThread).toHaveCount(0);
    await expect(page.locator('.context-panel__heading')).toContainText('Monthly project review');
    await expect(page.locator('.topic-header .tags-display')).toContainText('Project review');
    await expect(page.locator('.topic-page')).not.toContainText('Private review feedback');

    await page.locator('.topic-sidebar .action-dock__button--thread_settings').click();
    await expect(page.locator('.topic-settings__single-poll input')).toBeChecked();
    await expect(page.locator('.topic-settings__attachments-admin-only input')).toBeChecked();
    await expect(page.locator('.topic-settings__comment-length input')).toHaveValue('120');
  });
}

test('a member without permission cannot save a thread as a template', async ({ page }) => {
  await page.goto('/dev/discussions/test_save_as_template?member=1');
  await thread(page).locator('.action-menu--btn').click();
  await expect(page.locator('.v-overlay--active .action-dock__button--save_bookmark')).toBeVisible();
  await expect(page.locator('.action-dock__button--save_as_template')).toHaveCount(0);
});
