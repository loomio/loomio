import { test, expect } from '../fixtures.mjs';

const pollComments = ['Existing reply under the vote', 'Nested reply under the vote', 'Direct comment under the poll'];

test('keeps_poll_comments_visible_before_voting_and_after_removing_the_vote', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_vote')
  await expect(page.locator('.topic-list')).toContainText('Discussion comment outside the poll')
  for (const body of pollComments) { await expect(page.locator('.topic-list')).toContainText(body) }
  await page.locator('.stance-created .action-dock__button--add_comment').click()
  await page.locator('.reply-form .lmo-textarea div[contenteditable=true]').fill('A reply before voting')
  await page.locator('.reply-form .comment-form__submit-button').click()
  await expect(page.locator('.topic-list')).toContainText('A reply before voting')

  await page.locator('.poll-common-vote-form__button-text').click()
  await page.locator('.poll-common-vote-form__submit').click()
  for (const body of pollComments) { await expect(page.locator('.topic-list')).toContainText(body) }
  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A vote ready for conversation')
  await page.locator('.stance-created .action-dock__button--add_comment').click()
  await page.locator('.reply-form .lmo-textarea div[contenteditable=true]').fill('A reply immediately after voting')
  await page.locator('.reply-form .comment-form__submit-button').click()
  await expect(page.locator('.topic-list')).toContainText('A reply immediately after voting')
  await page.reload()
  await expect(page.locator('.topic-list')).toContainText('A reply immediately after voting')

  await page.locator('.poll-created .action-menu--btn').click()
  await page.locator('.v-overlay--active .action-dock__button--uncast_stance').click()
  await page.locator('.confirm-modal__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Vote removed')
  for (const body of pollComments) { await expect(page.locator('.topic-list')).toContainText(body) }
  await expect(page.locator('.topic-list')).toContainText('A reply immediately after voting')
  await expect(page.locator('.topic-list')).toContainText('Discussion comment outside the poll')
});

test('keeps_comments_visible_but_disables_vote_replies_and_mentions_until_closing', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_closed')
  await expect(page.locator('.topic-list')).toContainText('Discussion comment outside the poll')
  for (const body of pollComments) { await expect(page.locator('.topic-list')).toContainText(body) }
  await expect(page.locator('.stance-created .action-dock__button--add_comment')).toHaveCount(0)
  await page.locator('.poll-common-vote-form__button-text').click()
  await expect(page.locator('.poll-common-vote-form__reason .mention-notifications-count')).toHaveCount(0)
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').pressSequentially('@')
  await expect(page.locator('.suggestion-list:visible'), 'No mention popup is visible').toHaveCount(0);
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
  for (const body of pollComments) { await expect(page.locator('.topic-list')).toContainText(body) }
  await expect(page.locator('.stance-created .action-dock__button--add_comment')).toHaveCount(0)

  await page.locator('.poll-created .action-dock__button--close_poll').click()
  await page.locator('.confirm-modal__submit').click()
  await expect(page.locator('.confirm-modal')).toHaveCount(0)
  await expect(page.locator('.poll-common-outcome-modal')).toBeVisible()
  await page.locator('.poll-common-outcome-modal .dismiss-modal-button').click()
  await expect(page.locator('.poll-common-outcome-modal')).toHaveCount(0)
  for (const body of pollComments) { await expect(page.locator('.topic-list')).toContainText(body) }
  await expect(page.locator('.stance-created .action-dock__button--add_comment')).toBeVisible()
  await page.locator('.poll-created .action-menu--btn').click()
  await expect(page.locator('.action-dock__button--reopen_poll')).toHaveCount(0)
});
