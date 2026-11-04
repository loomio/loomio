const pageHelper = require('../helpers/pageHelper');

const pollComments = ['Existing reply under the vote', 'Nested reply under the vote', 'Direct comment under the poll'];

module.exports = {
  'keeps_poll_comments_visible_before_voting_and_after_removing_the_vote': test => {
    const page = pageHelper(test);
    page.loadPath('polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_vote');
    page.expectText('.topic-list', 'Discussion comment outside the poll');
    pollComments.forEach(body => page.expectText('.topic-list', body));
    page.expectElement('.stance-created .action-dock__button--add_comment');
    page.clickAndWait('.stance-created .action-dock__button--add_comment', '.reply-form .comment-form');
    page.fillIn('.reply-form .lmo-textarea div[contenteditable=true]', 'A reply before voting');
    page.click('.reply-form .comment-form__submit-button');
    page.expectText('.topic-list', 'A reply before voting');

    page.click('.poll-common-vote-form__button-text');
    page.click('.poll-common-vote-form__submit');
    pollComments.forEach(body => page.expectText('.topic-list', body));
    page.expectText('.poll-common-stance-created__reason', 'A vote ready for conversation');
    page.clickAndWait('.stance-created .action-dock__button--add_comment', '.reply-form .comment-form');
    page.fillIn('.reply-form .lmo-textarea div[contenteditable=true]', 'A reply immediately after voting');
    page.click('.reply-form .comment-form__submit-button');
    page.expectText('.topic-list', 'A reply immediately after voting');
    page.refreshAndWait();
    page.expectText('.topic-list', 'A reply immediately after voting');

    page.execute("document.querySelector('.poll-created .action-menu--btn').scrollIntoView({block: 'center'})");
    page.clickAndWait('.poll-created .action-menu--btn', '.v-overlay--active .action-dock__button--uncast_stance');
    page.pause(300);
    page.click('.v-overlay--active .action-dock__button--uncast_stance');
    page.click('.confirm-modal__submit');
    page.expectFlash('Vote removed');
    pollComments.forEach(body => page.expectText('.topic-list', body));
    page.expectText('.topic-list', 'A reply immediately after voting');
    page.expectText('.topic-list', 'Discussion comment outside the poll');
  },

  'keeps_comments_visible_but_disables_vote_replies_and_mentions_until_closing': test => {
    const page = pageHelper(test);
    page.loadPath('polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_closed');
    page.expectText('.topic-list', 'Discussion comment outside the poll');
    pollComments.forEach(body => page.expectText('.topic-list', body));
    page.expectNoElement('.stance-created .action-dock__button--add_comment');
    page.click('.poll-common-vote-form__button-text');
    page.expectNoElement('.poll-common-vote-form__reason .mention-notifications-count');
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', '@');
    test.execute(() => Array.from(document.querySelectorAll('.suggestion-list')).filter(element => element.getClientRects().length).length,
      [], result => test.assert.equal(result.value, 0, 'No mention popup is visible'));
    page.click('.poll-common-vote-form__submit');
    page.expectElement('.poll-common-current-vote');
    pollComments.forEach(body => page.expectText('.topic-list', body));
    page.expectNoElement('.stance-created .action-dock__button--add_comment');

    page.click('.poll-created .action-dock__button--close_poll');
    page.click('.confirm-modal__submit');
    page.expectNoElement('.confirm-modal', 5000);
    page.expectElement('.poll-common-outcome-modal');
    page.click('.poll-common-outcome-modal .dismiss-modal-button');
    page.expectNoElement('.poll-common-outcome-modal', 5000);
    pollComments.forEach(body => page.expectText('.topic-list', body));
    page.expectElement('.stance-created .action-dock__button--add_comment');
    page.clickAndWait('.poll-created .action-menu--btn', '.v-overlay--active .v-list');
    page.expectNoElement('.action-dock__button--reopen_poll');
  }
};
