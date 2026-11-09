import { test, expect } from '../fixtures.mjs';
import { signInViaPassword, signUpViaInvitation } from '../helpers/accounts.mjs';
import { submitVote } from '../helpers/polls.mjs';

// The scenario's poll has random options, and any of them will do.
const anyOption = page => page.locator('.poll-common-vote-form__button').first();

test('a guest invited to a poll signs up and votes', async ({ page }) => {
  await page.goto('/dev/polls/test_invite_to_poll?guest=1')
  await page.locator('.notification-title__link--poll').click()
  await signUpViaInvitation(page)
  await anyOption(page).click()
  await submitVote(page, 'A reason')
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
  await expect(page.locator('.poll-common-vote-form__submit')).toHaveCount(0)
  await expect(page.locator('.action-dock__button--edit_stance')).toBeVisible()
});

test('a member invited to a poll signs in and votes', async ({ page, flash }) => {
  await page.goto('/dev/polls/test_invite_to_poll')
  await page.locator('.notification-title__link--poll').click()
  await signInViaPassword(page, 'poll-member@example.com', 'password')
  await page.locator('.credential-prompt__dismiss').click()
  await anyOption(page).click()
  await submitVote(page, 'A reason')
  await expect(flash).toContainText('Vote created')
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
  await expect(page.locator('.poll-common-vote-form__submit')).toHaveCount(0)
});
