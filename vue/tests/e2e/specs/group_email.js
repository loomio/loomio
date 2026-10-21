const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'approves_a_stored_message_and_removes_it_from_the_pending_list': test => {
    const page = pageHelper(test);
    page.loadPath('setup_manual_oatmilk_unreleased_email');
    page.expectText('.group-emails-panel', 'Returnable bottle collection proposal');
    page.click('.group-emails-panel__approve');
    page.expectText('.v-overlay--active .v-card', 'Add alias');
    page.fillIn('.v-overlay--active input', 'Jamie');
    page.expectText('.v-overlay--active .v-list-item', 'Jamie Chen');
    page.click('.v-overlay--active .v-card .v-list-item');
    page.click('.v-overlay--active .v-card-actions .v-btn:last-child');
    page.expectNoElement('.v-overlay--active .v-card-actions');
    page.expectNoText('.group-emails-panel', 'Returnable bottle collection proposal');
    page.expectNoElement('.group-emails-panel__approve');
    test.refresh();
    page.waitFor('.group-emails-panel');
    page.expectNoText('.group-emails-panel', 'Returnable bottle collection proposal');
  }
};
