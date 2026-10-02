const pageHelper = require('../helpers/pageHelper');

const hiddenComments = ['Existing reply under the vote', 'Nested reply under the vote', 'Direct comment under the poll'];

module.exports = {
  'reveals_poll_conversation_after_voting_and_hides_it_after_removing_the_vote': test => {
    const page = pageHelper(test);
    page.loadPath('polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_vote');
    page.expectText('.topic-list', 'Discussion comment outside the poll');
    hiddenComments.forEach(body => page.expectNoText('.topic-list', body));
    page.expectNoElement('.stance-created .action-dock__button--add_comment');

    page.click('.poll-common-vote-form__button-text');
    page.click('.poll-common-vote-form__submit');
    hiddenComments.forEach(body => page.expectText('.topic-list', body));
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
    hiddenComments.forEach(body => page.expectNoText('.topic-list', body));
    page.expectNoText('.topic-list', 'A reply immediately after voting');
    page.expectText('.topic-list', 'Discussion comment outside the poll');
  },

  'keeps_poll_conversation_and_mentions_hidden_until_closing_even_after_voting': test => {
    const page = pageHelper(test);
    page.loadPath('polls/test_poll_scenario?scenario=poll_vote_conversation&poll_type=proposal&hide_results=until_closed');
    page.expectText('.topic-list', 'Discussion comment outside the poll');
    hiddenComments.forEach(body => page.expectNoText('.topic-list', body));
    page.expectNoElement('.stance-created .action-dock__button--add_comment');
    page.click('.poll-common-vote-form__button-text');
    page.expectNoElement('.poll-common-vote-form__reason .mention-notifications-count');
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', '@');
    test.execute(() => Array.from(document.querySelectorAll('.suggestion-list')).filter(element => element.getClientRects().length).length,
      [], result => test.assert.equal(result.value, 0, 'No mention popup is visible'));
    page.click('.poll-common-vote-form__submit');
    page.expectElement('.poll-common-current-vote');
    hiddenComments.forEach(body => page.expectNoText('.topic-list', body));
    page.expectNoElement('.stance-created .action-dock__button--add_comment');

    page.click('.poll-created .action-dock__button--close_poll');
    page.click('.confirm-modal__submit');
    page.expectNoElement('.confirm-modal', 5000);
    hiddenComments.forEach(body => page.expectText('.topic-list', body));
    page.expectElement('.stance-created .action-dock__button--add_comment');
  }
};
