require('coffeescript/register')
pageHelper = require('../helpers/page_helper')

module.exports = {
  'searches for and loads a thread by title': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--decisions')
    page.click('.navbar-search__button')
    page.fillIn('.navbar-search__input input', 'what star')
    page.expectText('.md-autocomplete-suggestions-container', 'What star sign are you?')
  }
}
