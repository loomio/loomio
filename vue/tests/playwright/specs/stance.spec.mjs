import { test, expect } from '../fixtures.mjs';
import { signInViaPassword, signUpViaInvitation } from '../helpers/accounts.mjs';

test('invite_guest_to_vote', async ({ page }) => {
  await page.goto('/dev/polls/test_invite_to_poll?guest=1')
  await page.click('main h1 a')
  await signUpViaInvitation(page)
  await page.click('.poll-common-vote-form__button')
  await page.fill('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit')
  await expect(page.locator('.action-dock__button--edit_stance')).toBeVisible()
  await expect(page.locator('.poll-common-vote-form__submit')).toHaveCount(0)
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
});

test('invite_member_to_vote', async ({ page }) => {
  await page.goto('/dev/polls/test_invite_to_poll')
  await page.click('main h1 a')
  await signInViaPassword(page, 'poll-member@example.com', 'password')
  await page.click('.credential-prompt__dismiss')
  await page.click('.poll-common-vote-form__button')
  await page.fill('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Vote created')
  await expect(page.locator('.poll-common-vote-form__submit')).toHaveCount(0)
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
});
