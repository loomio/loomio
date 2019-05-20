require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'invite_to_group': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_group')
    page.click('.membership-card__invite')
    page.selectFromAutocomplete('.announcement-form__invite input', 'test@example.com')
    page.expectText('.announcement-chip__content', 'test@example.com')
    page.click('.announcement-form__submit')
    page.expectText('.flash-root__message', '1 notifications sent')
  },

  'new_discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.discussions-card__new-thread-button')
    page.fillIn('.discussion-form__title-input', 'Immannounce dis')
    page.click('.discussion-form__submit')
    page.expectText('.flash-root__message', 'Thread started')
    page.expectElement('.announcement-form')
    page.click('.announcement-form__audience')
    page.click('.announcement-form__submit')
    page.expectText('.flash-root__message', '2 notifications sent')
  },

  'discussion_edited': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.action-dock__button--edit_thread')
    page.fillIn('.discussion-form__title-input', 'Yo reliability, whatsup? Its me, ya boi, testing')
    page.click('.discussion-form__submit')
    page.expectElement('.announcement-form')
    page.click('.announcement-form__audience')
    page.click('.announcement-form__submit')
    page.expectText('.flash-root__message', '2 notifications sent')
  },

  'announcement_created': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.membership-card__invite')
    page.expectElement('.announcement-form')
    page.selectFromAutocomplete('.announcement-form__invite input', 'jenn')
    page.expectText('.announcement-chip__content', 'Jennifer Grey')
    page.click('.announcement-form__submit')
    page.expectText('.flash-root__message', '1 notifications sent')
  },

  'poll_created': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.decision-tools-card__poll-type--proposal')
    page.fillIn('.poll-common-form-fields__title', 'Immanounce dis too')
    page.click('.poll-common-form__submit')
    page.expectText('.flash-root__message', 'Proposal started')
    page.expectElement('.announcement-form')
    page.selectFromAutocomplete('.announcement-form__invite input', 'jenn')
    page.expectText('.announcement-chip__content', 'Jennifer Grey')
    page.click('.announcement-form__submit')
    page.expectText('.flash-root__message', '1 notifications sent')
  },

  'poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPath('test_poll_in_discussion', { controller: 'polls' })
    page.click('.action-dock__button--edit_poll')
    page.fillIn('.poll-common-form-fields__title', 'Yo reliability, whatsup? Its me, ya boi, testing')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form')
    page.click('.announcement-form__audience')
    page.click('.announcement-form__submit')
    page.expectText('.flash-root__message', '1 notifications sent')
  },

  // 'outcome_created': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('test_proposal_poll_closed', { controller: 'polls' })
  //   page.click('.poll-common-set-outcome-panel__submit')
  //   page.fillIn('.poll-common-outcome-form__statement textarea', 'Immannounce all yall')
  //   page.click('.poll-common-outcome-form__submit')
  //   page.expectText('.flash-root__message', 'Outcome created')
  //   page.expectElement('.announcement-form')
  //   page.selectFromAutocomplete('.announcement-form__invite input', 'test@example.com')
  //   page.expectText('.announcement-chip__content', 'test@example.com')
  //   page.click('.announcement-form__submit')
  //   page.pause(3000)
  //   page.expectText('.flash-root__message', '1 notifications sent')
  // }
}
