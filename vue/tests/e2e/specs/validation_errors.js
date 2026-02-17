pageHelper = require('../helpers/pageHelper')

module.exports = {
  'discussion_form_shows_validation_errors': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.action-menu')
    page.click('.action-dock__button--edit_thread')
    page.clearField('.discussion-form__title-input input')
    page.click('.discussion-form__submit')
    page.expectFlash('Please check')
    page.expectFlash('title')
  },

  'group_form_shows_validation_errors': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.action-menu')
    page.click('.action-dock__button--edit_group')
    page.clearField('#group-name')
    page.click('.group-form__submit-button')
    page.expectFlash('name')
  },

  'poll_form_shows_validation_errors': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.pause(2000)
    page.execute("document.querySelector('.activity-panel__add-poll').click()")
    page.pause(1000)
    page.execute("document.querySelector('.decision-tools-card__poll-type--proposal').click()")
    page.waitFor('.poll-common-form-fields__title input')
    page.clearField('.poll-common-form-fields__title input')
    page.execute("document.querySelector('.poll-common-form__submit').click()")
    page.expectFlash('title')
  }
}
