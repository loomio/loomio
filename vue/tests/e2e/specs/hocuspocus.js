pageHelper = require('../helpers/pageHelper')

const DRAFT_TEXT  = 'hocuspocus draft persistence test'
const EDITOR      = '.comment-form .ProseMirror'
const SUBMIT_BTN  = '.comment-form__submit-button'

module.exports = {
  // Confirms auth, WebSocket connection, and model-save all work end-to-end.
  'submits_content_via_collab_editor': (test) => {
    const page = pageHelper(test)
    page.loadPath('setup_discussion')
    page.fillIn(EDITOR, DRAFT_TEXT)
    page.click(SUBMIT_BTN)
    page.expectText('.new-comment', DRAFT_TEXT)
  },

  // Types a draft, reloads (IndexedDB intact), and checks the draft survives.
  // Hocuspocus is a real-time relay; single-user draft persistence is IndexedDB.
  'restores_draft_after_reload': (test) => {
    const page = pageHelper(test)
    page.loadPath('setup_discussion')
    page.fillIn(EDITOR, DRAFT_TEXT)
    page.refresh()
    test.waitForElementPresent('.app-is-booted', 15000)
    test.expect.element(EDITOR).text.to.contain(DRAFT_TEXT).before(5000)
  },
}
