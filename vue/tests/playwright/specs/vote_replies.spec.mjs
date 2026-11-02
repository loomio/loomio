import { test, expect } from '../fixtures.mjs';

const pollComments = ['Existing reply under the vote', 'Nested reply under the vote', 'Direct comment under the poll'];

test('keeps_poll_comments_visible_before_voting_and_after_removing_the_vote', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_vote');
  await page.expectText('.topic-list', 'Discussion comment outside the poll');
  for (const body of pollComments) { await page.expectText('.topic-list', body); }
  await page.expectElement('.stance-created .action-dock__button--add_comment');
  await page.clickAndWait('.stance-created .action-dock__button--add_comment', '.reply-form .comment-form');
  await page.fillIn('.reply-form .lmo-textarea div[contenteditable=true]', 'A reply before voting');
  await page.click('.reply-form .comment-form__submit-button');
  await page.expectText('.topic-list', 'A reply before voting');

  await page.click('.poll-common-vote-form__button-text');
  await page.click('.poll-common-vote-form__submit');
  for (const body of pollComments) { await page.expectText('.topic-list', body); }
  await page.expectText('.poll-common-stance-created__reason', 'A vote ready for conversation');
  await page.clickAndWait('.stance-created .action-dock__button--add_comment', '.reply-form .comment-form');
  await page.fillIn('.reply-form .lmo-textarea div[contenteditable=true]', 'A reply immediately after voting');
  await page.click('.reply-form .comment-form__submit-button');
  await page.expectText('.topic-list', 'A reply immediately after voting');
  await page.refreshAndWait();
  await page.expectText('.topic-list', 'A reply immediately after voting');

  await page.execute("document.querySelector('.poll-created .action-menu--btn').scrollIntoView({block: 'center'})");
  await page.clickAndWait('.poll-created .action-menu--btn', '.v-overlay--active .action-dock__button--uncast_stance');
  await page.pause(300);
  await page.click('.v-overlay--active .action-dock__button--uncast_stance');
  await page.click('.confirm-modal__submit');
  await page.expectFlash('Vote removed');
  for (const body of pollComments) { await page.expectText('.topic-list', body); }
  await page.expectText('.topic-list', 'A reply immediately after voting');
  await page.expectText('.topic-list', 'Discussion comment outside the poll');
});

test('keeps_comments_visible_but_disables_vote_replies_and_mentions_until_closing', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_closed');
  await page.expectText('.topic-list', 'Discussion comment outside the poll');
  for (const body of pollComments) { await page.expectText('.topic-list', body); }
  await page.expectNoElement('.stance-created .action-dock__button--add_comment');
  await page.click('.poll-common-vote-form__button-text');
  await page.expectNoElement('.poll-common-vote-form__reason .mention-notifications-count');
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', '@');
  await expect(page.page.locator('.suggestion-list:visible'), 'No mention popup is visible').toHaveCount(0);
  await page.click('.poll-common-vote-form__submit');
  await page.expectElement('.poll-common-current-vote');
  for (const body of pollComments) { await page.expectText('.topic-list', body); }
  await page.expectNoElement('.stance-created .action-dock__button--add_comment');

  await page.click('.poll-created .action-dock__button--close_poll');
  await page.click('.confirm-modal__submit');
  await page.expectNoElement('.confirm-modal', 5000);
  await page.expectElement('.poll-common-outcome-modal');
  await page.click('.poll-common-outcome-modal .dismiss-modal-button');
  await page.expectNoElement('.poll-common-outcome-modal', 5000);
  for (const body of pollComments) { await page.expectText('.topic-list', body); }
  await page.expectElement('.stance-created .action-dock__button--add_comment');
  await page.clickAndWait('.poll-created .action-menu--btn', '.v-overlay--active .v-list');
  await page.expectNoElement('.action-dock__button--reopen_poll');
});
