import { test, expect } from '../fixtures.mjs';
import { pollAction, submitVote, voteOption } from '../helpers/polls.mjs';
import { editor } from '../helpers/editor.mjs';
import { postComment, replyForm, thread } from '../helpers/threads.mjs';

const scenario = hideResults =>
  `/dev/polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=${hideResults}`;
const pollComments = ['Existing reply under the vote', 'Nested reply under the vote', 'Direct comment under the poll'];
const replyToVote = page => page.locator('.stance-created .action-dock__button--add_comment');

async function expectConversation(page) {
  await expect(thread(page)).toContainText('Discussion comment outside the poll');
  for (const body of pollComments) { await expect(thread(page)).toContainText(body); }
}

test('poll comments stay visible before voting and after removing the vote', async ({ page, flash }) => {
  await page.goto(scenario('until_vote'));
  await expectConversation(page);
  await replyToVote(page).click();
  await postComment(page, 'A reply before voting', replyForm(page));
  await expect(thread(page)).toContainText('A reply before voting');

  await voteOption(page, 'agree').click();
  await submitVote(page);
  await expectConversation(page);
  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A vote ready for conversation');
  await replyToVote(page).click();
  await postComment(page, 'A reply after voting', replyForm(page));
  await expect(thread(page)).toContainText('A reply after voting');
  await page.reload();
  await expect(thread(page)).toContainText('A reply after voting');

  await pollAction(page, 'uncast_stance');
  await page.locator('.confirm-modal__submit').click();
  await expect(flash).toContainText('Vote removed');
  await expectConversation(page);
  await expect(thread(page)).toContainText('A reply after voting');
});

test('with results hidden until closing, comments stay visible but vote replies and mentions wait', async ({ page }) => {
  await page.goto(scenario('until_closed'));
  await expectConversation(page);
  await expect(replyToVote(page)).toHaveCount(0);

  await voteOption(page, 'agree').click();
  const reason = page.locator('.poll-common-vote-form__reason');
  await expect(reason.locator('.mention-notifications-count')).toHaveCount(0);
  await editor(reason).pressSequentially('@');
  await expect(page.locator('.suggestion-list'), 'no mention suggestions').toBeHidden();
  await submitVote(page);
  await expect(page.locator('.poll-common-current-vote')).toBeVisible();
  await expectConversation(page);
  await expect(replyToVote(page)).toHaveCount(0);

  await page.locator('.poll-created .action-dock__button--close_poll').click();
  await page.locator('.confirm-modal__submit').click();
  const outcome = page.locator('.poll-common-outcome-modal');
  await outcome.locator('.dismiss-modal-button').click();
  await expect(outcome).toHaveCount(0);
  await expectConversation(page);
  // Both votes take replies once the poll closes.
  await expect(replyToVote(page)).toHaveCount(2);
  await page.locator('.poll-created .action-menu--btn').click();
  await expect(page.locator('.v-overlay--active .action-dock__button--reopen_poll')).toHaveCount(0);
});
