require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'can preview': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_comment_preview')
    page.expectText('.preview-button.md-button', 'PREVIEW')
    page.fillIn('.comment-form textarea', 'Here is some text')
    page.click('.preview-button.md-button')
    page.expectText('.preview-pane', 'Patrick Swayze')
    page.expectText('.preview-pane', 'Here is some text')
  }
}
