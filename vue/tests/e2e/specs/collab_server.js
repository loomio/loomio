const pageHelper = require('../helpers/pageHelper')
const { randomUUID } = require('node:crypto')

const DRAFT_TEXT  = 'collaborative draft persistence test'
const EDITOR      = '.comment-form .ProseMirror'
const SUBMIT_BTN  = '.comment-form__submit-button'

const collabServer = require('../helpers/collabServer')

const DESCRIPTION = '.discussion-form .ProseMirror'
const SAVED       = 'Saved description'

// Counts occurrences in the editor, so doubled seed content fails loudly.
const expectOccurrences = (test, selector, text, count) => {
  test.execute((selector, text) => {
    return document.querySelector(selector).innerText.split(text).length - 1
  }, [selector, text], ({ value }) => test.assert.equal(value, count, `"${text}" appears ${count} time(s)`))
}

// Each attempt saves distinct content. Database IDs are reused after a reset;
// the content hash keeps drafts from earlier tests and retries from attaching.
const openDescriptionEditor = (page, test) => {
  const text = `${SAVED} ${test.currentTest.name} ${randomUUID()}`
  page.loadPath(`setup_discussion_html_description_edit?text=${encodeURIComponent(text)}`)
  test.waitForElementPresent(DESCRIPTION, 10000)
}

// Types at the end of the editor, leaving existing content in place.
const typeAtEnd = (test, selector, text) => {
  test.execute(selector => {
    const editor = document.querySelector(selector)
    editor.focus()
    const range = document.createRange()
    range.selectNodeContents(editor)
    range.collapse(false)
    const selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(range)
  }, [selector])
  test.sendKeys(selector, text)
}

const switchToTab = (test, index) => {
  test.window.getAllHandles(({ value }) => test.window.switchTo(value[index]))
}

const openSecondTab = (test) => {
  test.url(({ value: editUrl }) => {
    test.window.open('tab')
    switchToTab(test, 1)
    test.url(editUrl)
  })
  test.waitForElementPresent(DESCRIPTION, 15000)
}

module.exports = {
  afterEach: (test, done) => {
    test.window.getAllHandles(({ value }) => {
      value.slice(1).forEach(handle => {
        test.window.switchTo(handle)
        test.window.close()
      })
      test.window.switchTo(value[0])
      test.perform(() => collabServer.start())
      test.perform(() => done())
    })
  },

  // Confirms auth, WebSocket connection, and model-save all work end-to-end.
  'submits_content_via_collab_editor': (test) => {
    const page = pageHelper(test)
    page.loadPath('setup_discussion')
    page.fillIn(EDITOR, DRAFT_TEXT)
    page.click(SUBMIT_BTN)
    page.expectText('.new-comment', DRAFT_TEXT)
  },

  // Types a draft, reloads (IndexedDB intact), and checks the draft survives.
  // The collaboration server is a real-time relay; single-user draft persistence is IndexedDB.
  'restores_draft_after_reload': (test) => {
    const page = pageHelper(test)
    page.loadPath('setup_discussion')
    page.fillIn(EDITOR, DRAFT_TEXT)
    page.refresh()
    test.waitForElementPresent('.app-is-booted', 15000)
    test.expect.element(EDITOR).text.to.contain(DRAFT_TEXT).before(5000)
  },

  // Nothing on the server or in IndexedDB: the saved content shows once, and
  // still once after the server sync and the old 2-second fallback.
  'opens_saved_description_once': (test) => {
    const page = pageHelper(test)
    openDescriptionEditor(page, test)
    test.expect.element(DESCRIPTION).text.to.contain(SAVED).before(5000)
    page.pause(3000)
    expectOccurrences(test, DESCRIPTION, SAVED, 1)
  },

  // Text typed before any sync arrives is kept.
  'keeps_text_typed_immediately': (test) => {
    const page = pageHelper(test)
    openDescriptionEditor(page, test)
    typeAtEnd(test, DESCRIPTION, ' typed early')
    page.pause(3000)
    test.expect.element(DESCRIPTION).text.to.contain('typed early')
    expectOccurrences(test, DESCRIPTION, SAVED, 1)
  },

  // With the server down there is no sync to wait for; text typed straight
  // away must survive, then reach the server when it returns.
  'keeps_text_typed_while_server_is_down': (test) => {
    const page = pageHelper(test)
    test.perform(() => collabServer.stop())
    openDescriptionEditor(page, test)
    typeAtEnd(test, DESCRIPTION, ' typed offline')
    page.pause(3000)
    test.expect.element(DESCRIPTION).text.to.contain('typed offline')
    expectOccurrences(test, DESCRIPTION, SAVED, 1)
    test.perform(() => collabServer.start())
    page.pause(3000)
    test.expect.element(DESCRIPTION).text.to.contain('typed offline')
    expectOccurrences(test, DESCRIPTION, SAVED, 1)
  },

  // Two tabs on one description: no doubled content, edits travel both ways.
  'syncs_two_tabs_without_doubling': (test) => {
    const page = pageHelper(test)
    openDescriptionEditor(page, test)
    openSecondTab(test)
    typeAtEnd(test, DESCRIPTION, ' from B')

    switchToTab(test, 0)
    test.expect.element(DESCRIPTION).text.to.contain('from B').before(10000)
    typeAtEnd(test, DESCRIPTION, ' from A')

    switchToTab(test, 1)
    test.expect.element(DESCRIPTION).text.to.contain('from A').before(10000)
    expectOccurrences(test, DESCRIPTION, SAVED, 1)
    expectOccurrences(test, DESCRIPTION, 'from B', 1)
  },

  // The server has no persistence, so a restart loses its documents. The
  // draft returns from IndexedDB and must not merge with a second copy of the
  // saved content.
  'restores_draft_after_server_restart': (test) => {
    const page = pageHelper(test)
    openDescriptionEditor(page, test)
    typeAtEnd(test, DESCRIPTION, ' kept draft')
    page.pause(1000)
    test.url(({ value: editUrl }) => {
      page.goTo('dashboard')
      test.waitForElementPresent('.app-is-booted', 15000)
      test.perform(() => collabServer.stop())
      test.perform(() => collabServer.start())
      test.url(editUrl)
    })
    test.waitForElementPresent(DESCRIPTION, 15000)
    test.expect.element(DESCRIPTION).text.to.contain('kept draft').before(5000)
    page.pause(3000)
    expectOccurrences(test, DESCRIPTION, SAVED, 1)
    expectOccurrences(test, DESCRIPTION, 'kept draft', 1)
  },

  // Both tabs edit while the server is down. When it returns, empty, each
  // tab's edits reach the other and the saved content is not doubled.
  'syncs_edits_made_while_server_was_down': (test) => {
    const page = pageHelper(test)
    openDescriptionEditor(page, test)
    openSecondTab(test)
    test.perform(() => collabServer.stop())

    typeAtEnd(test, DESCRIPTION, ' B offline')
    switchToTab(test, 0)
    typeAtEnd(test, DESCRIPTION, ' A offline')
    page.pause(2000)
    test.expect.element(DESCRIPTION).text.to.not.contain('B offline')

    test.perform(() => collabServer.start())
    test.expect.element(DESCRIPTION).text.to.contain('B offline').before(30000)
    expectOccurrences(test, DESCRIPTION, SAVED, 1)

    switchToTab(test, 1)
    test.expect.element(DESCRIPTION).text.to.contain('A offline').before(30000)
    expectOccurrences(test, DESCRIPTION, SAVED, 1)
  },

  // A draft of old content must not attach after someone saves new content.
  'shows_newly_saved_content_instead_of_a_stale_draft': (test) => {
    const page = pageHelper(test)
    openDescriptionEditor(page, test)
    typeAtEnd(test, DESCRIPTION, ' stale draft')
    page.pause(1000)
    page.loadPath('update_html_description_elsewhere')
    test.waitForElementPresent(DESCRIPTION, 15000)
    test.expect.element(DESCRIPTION).text.to.contain('Saved elsewhere').before(5000)
    page.pause(2000)
    test.expect.element(DESCRIPTION).text.to.not.contain('stale draft')
    test.expect.element(DESCRIPTION).text.to.not.contain(SAVED)
    expectOccurrences(test, DESCRIPTION, 'Saved elsewhere', 1)
  },
}
