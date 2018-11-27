require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'is only visible to group coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_progress_card_coordinator')
    page.expectText('.group-progress-card', 'Activate your group')
  },

  'is only visible to group coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_progress_card_member')
    page.expectNoElement('.group-progress-card')
  },

  'adds a tick to completed tasks': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_progress_card_coordinator')
    page.expectElement('.group-progress-card__complete')
  },

  // 'displays a celebratory message when setup is complete': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_progress_card_coordinator')
  //   page.click('.group-progress-card__list-item:last-child')
  //   page.click('.poll-common-choose-type__poll-type--proposal')
  //   page.fillIn('.poll-common-form-fields__title', 'New proposal')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.announcement-form__submit')
  //   page.click('.dismiss-modal-button')
  //   page.pause()
  //   page.click('.group-theme__name--compact a')
  //   page.pause()
  //   page.expectText('.group-progress-card', "Nice! Your group is good to go!")
  // },

  'can be dismissed': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_progress_card_coordinator')
    page.click('.group-progress-card__dismiss')
    page.expectNoElement('.group-progress-card')
  },

  'reappears when user starts a new group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_progress_card_coordinator')
    page.click('.group-progress-card__dismiss')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--start-group')
    page.fillIn('#group-name', 'Freshest group')
    page.click('.group-form__submit-button')
    page.expectText('.group-progress-card__title', 'Activate your group')
  }
}
