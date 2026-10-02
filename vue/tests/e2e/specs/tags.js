const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'restricted_member_can_start_a_thread_with_template_tags': test => {
    const page = pageHelper(test);
    page.loadPath('setup_member_discussion_with_restricted_tags');
    page.expectElement('.tags-field__input.v-autocomplete');
    page.expectText('.tags-field__input .v-chip', 'Existing');
    page.fillIn('#discussion-title', 'Thread with existing tags');
    page.fillIn('.tags-field__input input:not([type="hidden"])', 'Other');
    page.click('.v-overlay--active .v-list-item');
    page.expectText('.tags-field__input', 'Other');
    page.fillIn('.tags-field__input input:not([type="hidden"])', 'Unauthorized new tag');
    test.sendKeys('.tags-field__input input:not([type="hidden"])', test.Keys.ENTER);
    page.click('#discussion-title');
    page.expectNoText('.tags-field__input .v-chip', 'Unauthorized new tag');
    page.click('.discussion-form__submit');
    page.expectFlash('Discussion started');
    page.expectText('.context-panel__heading', 'Thread with existing tags');
    page.expectText('.tags-display', 'Existing');
    page.expectText('.tags-display', 'Other');
    page.expectNoText('.tags-display', 'Unauthorized new tag');
  }
};
