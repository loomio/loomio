import { test, expect } from '../fixtures.mjs';
import { pollAction } from '../helpers/polls.mjs';

const settings = scope => ({
  comments: scope.locator('.topic-settings__comments input'),
  attachmentsAdminOnly: scope.locator('.topic-settings__attachments-admin-only input'),
  commentLength: scope.locator('.topic-settings__comment-length input'),
});

for (const [state, params] of [
  ['an open proposal', ''], ['a scheduled proposal', '?scheduled=1'], ['a closed proposal', '?closed=1'],
  ['a ranked choice poll', '?poll_type=stv'],
  ['a member\'s proposal', '?member=1&members_can_create_templates=1']
]) {
  test(`saves ${state} as a template and starts a poll from it`, async ({ page }) => {
    await page.goto(`/dev/polls/save_poll_as_template${params}`);
    await pollAction(page, 'save_as_template');
    await expect(page).toHaveURL(/\/poll_templates\/new\?poll_id=\d+/);
    const pollId = new URL(page.url()).searchParams.get('poll_id');
    // The form loads its copy from the URL alone.
    await page.reload();

    const form = page.locator('.poll-template-form');
    const help = form.locator('.poll-template-form__help');
    await expect(help).toContainText('Templates let anyone in your group reuse');
    await expect(help.locator('a')).toHaveAttribute('href', /\/en\/user_manual\/polls\/poll_templates/);
    await expect(form.locator('.poll-template-form-fields__process-name input')).toHaveValue('Article proposal');
    await expect(form.locator('.poll-template-form-fields__title input')).toHaveValue('Article proposal');
    await expect(form.locator('.tags-field__input')).toContainText('Consent');
    await expect(form.locator('.tags-field__input')).toContainText('Significant decisions');
    await expect(form.locator('.poll-template-form-fields__details')).toContainText('Proposed article changes');
    await expect(form).toContainText('I support these changes');
    await expect(form).toContainText('These changes need revision');
    const templateSettings = settings(form);
    await templateSettings.comments.uncheck();
    await templateSettings.attachmentsAdminOnly.check();
    await templateSettings.commentLength.fill('120');
    await form.locator('.poll-template-form-fields__process-subtitle input').fill('Reusable article consent process');
    await form.locator('.poll-template-form__submit').click();
    await expect(form).toHaveCount(0);
    await expect(page.locator('.context-panel__heading')).toContainText('Article proposal');

    const response = await page.request.get(`/api/v1/polls/${pollId}`);
    const groupId = (await response.json()).polls[0].group_id;
    await page.goto(`/p/new?group_id=${groupId}`);
    if (state === 'a ranked choice poll') { await page.locator('.poll-common-choose-template__poll').click(); }
    await page.locator('.decision-tools-card__poll-type', { hasText: 'Article proposal' }).click();

    const pollForm = page.locator('.poll-common-form');
    await expect(pollForm.locator('.poll-common-form__opens-immediately input')).toBeChecked();
    await expect(pollForm).toContainText('I support these changes');
    await expect(pollForm).toContainText('These changes need revision');
    await pollForm.locator('.poll-common-form__more-settings').click();
    const pollSettings = settings(pollForm);
    await expect(pollSettings.comments).not.toBeChecked();
    await expect(pollSettings.attachmentsAdminOnly).toBeChecked();
    await expect(pollSettings.commentLength).toHaveValue('120');
    await pollForm.locator('.poll-common-form__submit').click();
    await expect(pollForm).toHaveCount(0);
    await expect(page.locator('.topic-header .tags-display')).toContainText('Consent');
    await expect(page.locator('.topic-header .tags-display')).toContainText('Significant decisions');

    await page.locator('.topic-sidebar .action-dock__button--thread_settings').click();
    const threadForm = page.locator('.topic-arrangement-form');
    const threadSettings = settings(threadForm);
    await expect(threadForm.locator('.topic-settings__single-poll')).toHaveCount(0);
    await expect(threadSettings.comments).not.toBeChecked();
    await expect(threadSettings.attachmentsAdminOnly).toBeChecked();
    await expect(threadSettings.commentLength).toHaveValue('120');
  });
}

test('a member without permission cannot save a poll as a template', async ({ page }) => {
  await page.goto('/dev/polls/save_poll_as_template?member=1');
  await page.locator('.poll-created .action-menu--btn').click();
  await expect(page.locator('.v-overlay--active .action-dock__button--save_bookmark')).toBeVisible();
  await expect(page.locator('.action-dock__button--save_as_template')).toHaveCount(0);
  await expect(page.locator('.action-dock__button--make_a_copy')).toHaveCount(0);
});
