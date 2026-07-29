pageHelper = require('../helpers/pageHelper')

// Screenshots for user_manual/discussions/* sections of help.loomio.com
// Run:   bin/screenshots discussions.js
// Dark:  bin/screenshots discussions.js --dark
//
// Each test loads one scenario, then captures multiple screenshots.
// Output goes to docs/src/user_manual/screenshots/light/ (or dark/).
// Selectors may need tweaking after a first run with --show.

module.exports = {

  // ─── Main thread view ────────────────────────────────────────────────────────
  'discussion_thread': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_thread')

    // Full thread overview used on the discussions index page
    page.screenshot('discussion-example')

    // Thread context panel (opening message + title)
    page.screenshotElement('#context', 'thread_context')

    // Full thread showing navigation, context, comments, timeline
    page.screenshot('thread_navigation')

    // Comment section with reactions
    page.screenshotElement('.new-comment', 'comment')

    // Reactions on a comment
    page.screenshotElement('.reactions-display', 'reactions')
    page.screenshotElement('.reactions-display', 'reaction')

    // Unread comment (yellow line) — last comment from jennifer appears unread
    page.screenshotElement('.strand-item:last-child', 'thread_unread_comments')

    // Reply to a comment
    page.screenshotElement('.strand-item--deep', 'comment_reply')

    // Seen by + engagement row below context (tiny ~124x34 in originals)
    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(300)
    page.screenshotElement('.context-panel__seen_by_count', 'thread_engagement')

    // Thread timeline (right side) — screenshot full viewport to show it
    page.screenshot('thread_timeline_1')
    page.screenshot('thread_display')
    page.screenshot('thread_layout_options')
  },

  // ─── Thread display options menu ─────────────────────────────────────────────
  'discussion_seen_by': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_thread')

    // Scroll context into view before interacting (page loads at unread position)
    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(300)

    // Open seen by modal — be specific so we hit the dialog not some other v-card
    page.click('.context-panel__seen_by_count')
    page.waitFor('.v-dialog .v-card')
    page.pause(500)
    page.screenshotElement('.v-dialog .v-card', 'thread_seenby')

    // Close and screenshot seen-by count row
    page.escape()
    page.pause(300)
    page.screenshotElement('.context-panel__seen_by_count', 'thread_notified')
  },

  // ─── Starting a new discussion ───────────────────────────────────────────────
  'discussion_start_new': (test) => {
    page = pageHelper(test)

    // Group page — screenshot the "New Discussion" button
    page.loadPath('screenshots/screenshot_group_page')
    page.screenshotElement('.discussions-panel__new-thread-button', 'new-discussion-button')

    // New discussion form directly (controller redirects to /d/new?group_id=...)
    page.loadPath('screenshots/screenshot_discussion_new_form')
    page.waitFor('.discussion-form')
    page.pause(500)

    // Blank form
    page.screenshotElement('.discussion-form', 'new-discussion-example')

    // Fill in title and context so the form looks realistic
    page.fillIn('.discussion-form__title-input input', 'Preparing a new sustainability service')
    page.fillIn('.html-editor__textarea .ProseMirror', 'We\'ve been asked to explore launching a new sustainability advisory service.')
    page.pause(300)
    page.screenshotElement('.discussion-form', 'direct-discussion-example')
  },

  // ─── Formatting toolbar ──────────────────────────────────────────────────────
  // Originals show: "Context" label + placeholder/example text + EXPANDED toolbar
  // Use the empty new-discussion form so the placeholder text shows, expand toolbar,
  // and capture the whole .editor area (label + textarea + menubar).
  'discussion_formatting': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_new_form')
    page.waitFor('.discussion-form')
    page.pause(500)

    // Focus the context editor and expand the toolbar
    page.execute("document.querySelector('.discussion-form .ProseMirror').focus()")
    page.pause(200)
    page.execute("document.querySelector('.discussion-form .html-editor__expand').click()")
    page.pause(400)

    // Full formatting toolbar from the discussion context editor
    // (Originals also show example text, but at minimum we can give same framing)
    page.screenshotElement('.discussion-form .editor', 'thread_format_bar')
    page.screenshotElement('.discussion-form .editor', 'format_insert_image')
    page.screenshotElement('.discussion-form .editor', 'format_insert_example')
    page.screenshotElement('.discussion-form .editor', 'format_image_example')
    page.screenshotElement('.discussion-form .editor', 'format_link')
    page.screenshotElement('.discussion-form .editor', 'thread_insert_emoji')
    page.screenshotElement('.discussion-form .editor', 'format_heading')
    page.screenshotElement('.discussion-form .editor', 'format_bold')
    page.screenshotElement('.discussion-form .editor', 'thread_bullets')
    page.screenshotElement('.discussion-form .editor', 'format_numbers')
    page.screenshotElement('.discussion-form .editor', 'format_tasks')
    page.screenshotElement('.discussion-form .editor', 'thread_colors')
    page.screenshotElement('.discussion-form .editor', 'thread_align')
    page.screenshotElement('.discussion-form .editor', 'format_embed')
    page.screenshotElement('.discussion-form .editor', 'thread_quote')
    page.screenshotElement('.discussion-form .editor', 'thread_codeblock')
    page.screenshotElement('.discussion-form .editor', 'thread_line')
    page.screenshotElement('.discussion-form .editor', 'thread_table')
    page.screenshotElement('.discussion-form .editor', 'format_attach')
    page.screenshotElement('.discussion-form .editor', 'thread_file_remove')
  },

  // ─── Comment editing and history ─────────────────────────────────────────────
  'discussion_comment_edit': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_edited_comment')

    // Comment with edit indicator (show_history dock button appears on edited comments)
    page.screenshotElement('.new-comment', 'edit_comment')
    page.screenshotElement('.new-comment', 'comment_history_button')

    // Open edit history modal via the show_history dock button
    page.click('.new-comment .action-dock__button--show_history')
    page.pause(500)
    page.screenshotElement('.v-dialog .v-card', 'comment_history_modal')
    page.escape()
    page.pause(300)

    // Comment editing state — open the 3-dot menu
    page.pause(200)
    page.click('.new-comment .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(300)
    page.screenshotElement('.v-overlay .v-list', 'comment_edit')
    page.screenshotElement('.v-overlay .v-list', 'comment_show_edits')

    page.escape()
    page.pause(300)
    page.screenshotElement('.new-comment', 'comment_edits')
    page.screenshotElement('.new-comment', 'comment_copy_link')
  },

  // ─── Comment discard / restore / delete ──────────────────────────────────────
  'discussion_comment_discard': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_thread')

    // Open 3-dot menu on a comment
    page.pause(200)
    page.click('.strand-item:nth-child(2) .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(300)
    page.screenshotElement('.v-overlay .v-list', 'comment_discard')
    page.escape()
    page.pause(300)

    // Delete confirmation dialog
    page.pause(200)
    page.click('.strand-item:nth-child(2) .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(200)
    page.click('.action-dock__button--discard_comment')
    page.pause(500)
    page.screenshotElement('.v-overlay .v-card', 'comment_delete_message')
    page.escape()
    page.pause(300)
    page.screenshotElement('.new-comment', 'comment_delete')
    page.screenshotElement('.new-comment', 'comment_restore')
  },

  // ─── Moving comments ─────────────────────────────────────────────────────────
  'discussion_move_comments': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_forkable')

    // Open 3-dot menu → Move item
    page.pause(200)
    page.click('.strand-item:nth-child(2) .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(300)
    page.screenshotElement('.v-overlay .v-list', 'comment_move')

    // Click move item to enter selection mode
    page.click('.action-dock__button--move_event')
    page.pause(500)
    page.screenshotElement('.strand-list', 'comment_select')

    // Select a comment and show the move banner
    page.click('.strand-item:nth-child(2) .strand-item__selector')
    page.pause(300)
    page.screenshotElement('.move-items-banner', 'move_items')
    page.screenshotElement('.move-items-banner', 'move_items_new_thread')
    page.screenshotElement('.strand-list', 'new_thread')
  },

  // ─── Notifying people ────────────────────────────────────────────────────────
  'discussion_notifications': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_thread')

    // Original thread_invite_icon is the FULL context panel (title + body + action dock)
    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(200)
    page.screenshotElement('#context', 'thread_invite_icon')
    page.screenshotElement('#context', 'thread_interact')

    // Click invite icon to open invite dialog
    page.click('#context .action-dock__button--announce_thread')
    page.waitFor('.v-dialog .v-card')
    page.pause(500)
    page.screenshotElement('.v-dialog .v-card', 'thread_invite')
    page.screenshotElement('.v-dialog .v-card', 'invite_guest')
    page.escape()
    page.pause(300)

    // Comment with @mention visible
    page.screenshotElement('.new-comment:last-child', 'comment_mention')
    page.screenshotElement('.new-comment:last-child', 'mentioning_group_1')
    page.screenshotElement('.new-comment:last-child', 'mentioning_group_2')

    // Notification field on the comment form (large captures showing tagged users)
    // Focus comment editor, then capture the notify-fields area below it
    page.execute("document.querySelector('.add-comment-panel .ProseMirror').focus()")
    page.pause(400)
    page.execute("document.querySelector('.add-comment-panel').scrollIntoView({block: 'center'})")
    page.pause(300)
    page.screenshotElement('.add-comment-panel', 'thread_notification')
    page.screenshotElement('.add-comment-panel', 'thread_notify_user')
    page.screenshotElement('.add-comment-panel', 'thread_notify_email')

    // Reaction on comment
    page.screenshotElement('.new-comment .action-dock', 'reaction')
  },

  // ─── Thread edit ─────────────────────────────────────────────────────────────
  'discussion_thread_edit': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_thread')

    // edit_thread is a top-level dock button (dock:1) — click directly, no menu needed
    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(300)
    page.click('#context .action-dock__button--edit_thread')
    page.waitFor('.discussion-form')
    page.pause(500)
    page.screenshotElement('.discussion-form', 'thread_editcontext')
    page.escape()
    page.pause(400)

    // Edit comment that appears after updating context
    page.screenshotElement('.strand-item', 'thread_edit_comment')
    page.screenshotElement('.strand-item', 'thread_context_edit')
    page.screenshotElement('.strand-item', 'thread_notification_history')
    page.screenshotElement('.strand-item', 'comment_notification_history')
    page.screenshotElement('.strand-item', 'comment_notification_example')
    page.screenshotElement('.strand-item', 'poll_notification_history')
    page.screenshotElement('.strand-item', 'poll_notification_example')
  },

  // ─── Thread admin actions ─────────────────────────────────────────────────────
  'discussion_admin_actions': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_thread')

    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(200)

    // Open overflow menu and take all menu-view screenshots before acting
    page.click('#context .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(400)
    page.screenshotElement('.v-overlay .v-list', 'thread_admin')
    page.screenshotElement('.v-overlay .v-list', 'thread_print_thread')
    page.screenshotElement('.v-overlay .v-list', 'thread_pin_thread')

    // Close discussion (menu: true) — opens ConfirmModal
    page.click('.action-dock__button--close_thread')
    page.pause(500)
    page.screenshotElement('.v-card', 'thread_close_thread')
    page.screenshotElement('.v-card', 'close_thread')
    page.escape()
    page.pause(400)

    // Show action dock after (thread still open, reopen button won't appear until actually closed)
    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(200)
    page.screenshotElement('#context .action-dock', 'thread_reopen')

    // Make a copy (menu: true) — navigates to /d/new?discussion_id=...
    page.click('#context .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(300)
    page.click('.action-dock__button--make_a_copy')
    page.waitFor('.discussion-form')
    page.pause(500)
    page.screenshotElement('.discussion-form', 'thread_copy')
    page.screenshotElement('.discussion-form', 'thread_copy_start')

    // Reload thread since make_a_copy navigated away
    page.loadPath('screenshots/screenshot_discussion_thread')
    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(300)

    // Move to group (menu: true)
    page.click('#context .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(300)
    page.click('.action-dock__button--move_thread')
    page.waitFor('.v-dialog .v-card')
    page.pause(500)
    page.screenshotElement('.v-dialog .v-card', 'thread_move_to')
    page.screenshotElement('.v-dialog .v-card', 'destination_group')
    page.escape()
    page.pause(400)

    // Delete discussion (menu: true)
    page.execute("document.querySelector('#context').scrollIntoView({block: 'center'})")
    page.pause(200)
    page.click('#context .action-menu--btn')
    page.waitFor('.v-list-item')
    page.pause(300)
    page.click('.action-dock__button--discard_thread')
    page.waitFor('.v-dialog .v-card')
    page.pause(500)
    page.screenshotElement('.v-dialog .v-card', 'delete_thread_1')
    page.screenshotElement('.v-dialog .v-card', 'delete_thread')
    page.escape()
    page.pause(400)
  },

  // ─── Closed discussions on group page ─────────────────────────────────────────
  'discussion_group_closed': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_group_page')

    // Filter dropdown — click to change from Open to Closed
    page.screenshotElement('.discussions-panel', 'sort_threads_on_group_page')
    page.click('.discussions-panel__filters')
    page.waitFor('.v-list-item')
    page.pause(300)
    page.screenshotElement('.v-overlay .v-list', 'closed_thread_filter')

    page.click('.discussions-panel__filters-closed')
    page.waitFor('.discussions-panel')
    page.pause(500)
    page.screenshotElement('.discussions-panel', 'closed_threads')
  },

  // ─── Tasks ───────────────────────────────────────────────────────────────────
  'discussion_tasks': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_discussion_thread')

    // Focus ProseMirror programmatically (sticky footer blocks WebDriver clicks)
    page.pause(2000)
    page.execute("document.querySelector('.add-comment-panel .ProseMirror').focus()")
    page.waitFor('.add-comment-panel .menubar')
    page.pause(300)

    // Expand the toolbar so the task-list button is visible
    page.execute("document.querySelector('.add-comment-panel .html-editor__expand').click()")
    page.pause(400)
    page.execute("document.querySelector('.add-comment-panel').scrollIntoView({block: 'center'})")
    page.pause(300)

    // Task list button in toolbar (originals ~1500x460 show toolbar + label)
    page.screenshotElement('.add-comment-panel', 'tasklist1')
    page.screenshotElement('.add-comment-panel', 'tasklist2')
    page.screenshotElement('.add-comment-panel', 'taskreminderform')

    // Posted comment with a task visible (best-effort — needs real posted task)
    page.screenshotElement('.new-comment', 'task_list')
    page.screenshotElement('.new-comment', 'taskdone')
  },

  // ─── Direct discussion ────────────────────────────────────────────────────────
  'discussion_direct': (test) => {
    page = pageHelper(test)
    page.loadPath('screenshots/screenshot_direct_discussion')

    // New direct discussion form
    page.waitFor('.discussion-form')
    page.pause(300)
    page.screenshotElement('.discussion-form', 'direct-discussion-example')

    // Open sidebar nav drawer to show direct discussions link
    page.execute("document.querySelector('.navbar__sidenav-toggle').click()")
    page.waitFor('.sidenav-left')
    page.pause(400)
    page.screenshotElement('.sidenav-left', 'direct-discussion-sidebar')
  },
}
