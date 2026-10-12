const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'leaving a group clears an authored poll needing a vote': test => {
    const page = pageHelper(test);
    page.loadPath('setup_group_with_authored_stv_poll');
    page.click('.group-page-polls-tab');
    page.expectText('.polls-panel', 'Working group election');
    page.click('.action-menu');
    page.click('.action-dock__button--leave_group');
    page.click('.confirm-modal__submit');
    page.expectFlash('You have left this group');
    page.waitFor('.dashboard-page');
    page.expectNoElement('.dashboard-page .poll-common-preview');
    page.goTo('dashboard/polls_to_vote_on');
    page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
    page.refreshAndWait();
    page.expectText('.polls-to-vote-on-page', 'There are no polls you need to vote on');
  }
};
