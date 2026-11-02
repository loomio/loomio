import { test, expect } from '../fixtures.mjs';

test('invite_guest_to_vote', async ({ lmo: page }) => {
  await page.loadPathNoApp('polls/test_invite_to_poll?guest=1')
  await page.click('main h1 a')
  await page.pause(1000)
  await page.signUpViaInvitation()
  await page.click('.poll-common-vote-form__button')
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit')
  await page.expectElement('.action-dock__button--edit_stance')
  await page.expectNoElement('.poll-common-vote-form__submit')
  await page.expectElement('.poll-common-current-vote')
});

test('invite_member_to_vote', async ({ lmo: page }) => {
  await page.loadPathNoApp('polls/test_invite_to_poll')
  await page.click('main h1 a')
  await page.pause(1000)
  await page.signInViaPassword('poll-member@example.com', 'password')
  await page.click('.credential-prompt__dismiss')
  await page.click('.poll-common-vote-form__button')
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit')
  await page.expectFlash('Vote created')
  await page.expectNoElement('.poll-common-vote-form__submit')
  await page.expectElement('.poll-common-current-vote')
});
