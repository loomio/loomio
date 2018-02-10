require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'searches for and loads a thread by title': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion', '.sidebar__list-item-button--decisions')
    page.click('.sidebar__list-item-button--decisions', '.navbar-search__button')
    page.click('.navbar-search__button', '.navbar-search__input input')
    page.fillIn('.navbar-search__input input', 'what star')
    page.waitFor('.md-autocomplete-suggestions-container')
    page.expectText('.md-autocomplete-suggestions-container', 'What star sign are you?')
  }
}
