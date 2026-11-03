import { test, expect } from '../fixtures.mjs';
import { signInViaPassword, signUpViaInvitation } from '../helpers/accounts.mjs';

test('invite_guest_to_vote', async ({ page }) => {
  await page.goto('/dev/polls/test_invite_to_poll?guest=1')
  await page.locator('main h1 a').click()
  await signUpViaInvitation(page)
  await page.locator('.poll-common-vote-form__button').click()
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.action-dock__button--edit_stance')).toBeVisible()
  await expect(page.locator('.poll-common-vote-form__submit')).toHaveCount(0)
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
});

test('invite_member_to_vote', async ({ page }) => {
  await page.goto('/dev/polls/test_invite_to_poll')
  await page.locator('main h1 a').click()
  await signInViaPassword(page, 'poll-member@example.com', 'password')
  await page.locator('.credential-prompt__dismiss').click()
  await page.locator('.poll-common-vote-form__button').click()
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Vote created')
  await expect(page.locator('.poll-common-vote-form__submit')).toHaveCount(0)
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
});
