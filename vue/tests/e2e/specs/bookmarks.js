
pageHelper = require('../helpers/pageHelper')

module.exports = {
  'can_save_view_and_remove_a_bookmark': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'a comment worth bookmarking')
    page.click('.comment-form__submit-button')
    page.expectFlash('Comment added')
    page.pause()
    page.click('.new-comment .action-menu')
    page.click('.action-dock__button--save_bookmark')
    page.expectFlash('Bookmark saved')

    page.goTo('bookmarks')
    page.expectText('.bookmarks-page', 'a comment worth bookmarking')

    page.click('.bookmarks-page button[title="Remove bookmark"]')
    page.expectFlash('Bookmark removed')
    page.expectNoElement('.bookmarks-page .v-list-item')
  }
}
