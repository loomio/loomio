
pageHelper = require('../helpers/pageHelper')

module.exports = {
  'can_save_view_and_remove_a_bookmark': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'a comment worth bookmarking')
    page.click('.comment-form__submit-button')
    page.expectFlash('Comment added')
    page.pause()
    page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('a comment worth bookmarking')).querySelector('.action-menu--btn').click()")
    page.waitFor('.action-dock__button--save_bookmark')
    page.execute("Array.from(document.querySelectorAll('.action-dock__button--save_bookmark')).find(el => el.offsetParent).click()")
    page.expectFlash('Bookmark saved')

    page.goTo('bookmarks')
    page.expectText('.bookmarks-page', 'What star sign are you?')
    page.expectText('.bookmarks-page', 'Comment by Patrick Swayze')

    page.click('.bookmarks-page button[title="Remove bookmark"]')
    page.expectFlash('Bookmark removed')
    page.expectNoElement('.bookmarks-page .v-list-item')
  }
}
