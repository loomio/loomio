describe 'Discussion Page', ->

  page = require './helpers/page_helper.coffee'

  describe 'starting a thread via start menu', ->
    it 'preselects current group', ->
      page.loadPath 'setup_dashboard'
      page.click '.sidebar__list-item-button--muted'
      page.clickFirst '.thread-preview__link'
      page.click '.sidebar__list-item-button--start-thread'
      page.expectText '.discussion-form__group-select', 'Muted Point Blank'

  describe 'viewing while logged out', ->
    it 'should display content for a public thread', ->
      page.loadPath('view_open_group_as_visitor')
      page.expectText('.group-theme__name', 'Open Dirty Dancing Shoes')
      page.expectText('.thread-previews-container--unpinned', 'I carried a watermelon')
      page.expectText('.navbar__right', 'LOG IN')
      page.click('.thread-preview__link')
      page.expectText('.context-panel', 'I carried a watermelon')

    it 'should display timestamps on content', ->
      page.loadPath('view_open_group_as_non_member')
      page.click('.thread-preview__link')
      page.expectElement('.timeago')

  describe 'edit thread', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'lets you edit title, context and privacy', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'
      page.fillIn('.discussion-form__title-input', 'better title')
      page.fillIn('.discussion-form textarea', 'improved description')
      page.click('.discussion-form__private')
      page.click('.discussion-form__update')
      page.expectText('.context-panel', 'better title')
      page.expectText('.context-panel', 'improved description')
      page.expectText('.context-panel', 'Private')
      page.expectText('.thread-item__title', 'edited the thread title')

    xit 'does not store cancelled thread info', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'

      page.fillIn('.discussion-form__title-input', 'dumb title')
      page.fillIn('.discussion-form textarea', 'rubbish description')

      page.click('.modal-cancel')
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'

      page.expectNoText('.discussion-form__title-input', 'dumb title')
      page.expectNoText('.discussion-form textarea', 'rubbish description')

    xit 'lets you view thread revision history', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'
      page.fillIn '.discussion-form__title-input', 'Revised title'
      page.fillIn '.discussion-form textarea', 'Revised description'
      page.click '.discussion-form__update'
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'
      page.fillIn '.discussion-form__title-input', 'Revised title'
      page.fillIn '.discussion-form textarea', 'Revised description'
      page.click '.discussion-form__update'
      page.click '.context-panel__edited'
      page.expectText '.revision-history-modal__body', 'Revised title'
      page.expectText '.revision-history-modal__body', 'Revised description'
      page.expectText '.revision-history-modal__body', 'What star sign are you?'

  describe 'reading a thread', ->
    fit 'can display an unread content line', ->
      page.loadPath 'setup_unread_discussion'
      page.expectText '.activity-card', 'New Activity'
      browser.refresh()
      page.expectNoText '.activity-card', 'New Activity'

  describe 'muting and unmuting a thread', ->
    it 'lets you mute and unmute', ->
      page.loadPath 'setup_multiple_discussions'
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--mute'
      page.click '.mute-explanation-modal__mute-thread'
      page.expectFlash 'Thread muted'
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--unmute'
      page.expectFlash 'Thread unmuted'

  describe 'move thread', ->
    it 'lets you move a thread', ->
      page.loadPath 'setup_multiple_discussions'
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--move'
      page.selectOption '.move-thread-form__group-dropdown', 'Point Break'
      page.click '.move-thread-form__submit'
      page.sleep()
      page.expectText '.thread-item__title', 'Patrick Swayze moved the thread from Dirty Dancing Shoes'
      page.expectText '.group-theme__name--compact','Point Break'

  describe 'delete thread', ->
    it 'lets coordinators and thread authors delete threads', ->
      page.loadPath 'setup_discussion'
      page.click '.context-panel__dropdown-button'
      page.click '.context-panel__dropdown-options--delete button'
      page.click '.delete-thread-form__submit'

      page.expectFlash 'Thread deleted'
      page.expectText '.group-theme__name', 'Dirty Dancing Shoes'
      page.expectNoText '.discussions-card', 'What star sign are you?'

  describe 'pin thread', ->
    it 'can pin from the discussion page', ->
      page.loadPath 'setup_discussion'
      page.click '.context-panel__dropdown-button'
      page.click '.context-panel__dropdown-options--pin button'

      page.expectText '.pin-thread-modal', 'Pinned threads always appear'
      page.click '.pin-thread-modal__submit'

      page.expectFlash 'Thread pinned'
      page.expectElement '.context-panel__pin'

      page.click '.sidebar__list-item-button--recent'
      page.expectElement '.thread-preview__pin'

  describe 'changing thread email settings', ->
    beforeEach ->
      page.loadPath('setup_discussion')
    it 'lets you change thread volume', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--email-settings',
                 '#volume-loud',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed activity in this thread.'

    it 'lets you change the volume for all threads in the group', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--email-settings',
                 '#volume-loud',
                 '.change-volume-form__apply-to-all',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed all activity in this group.'

  describe 'joining the group', ->
    fit 'allows logged in users to join a group and comment', ->
      page.loadPath 'view_open_group_as_non_member'
      page.click '.thread-preview__link'
      page.click '.join-group-button__join-group'
      page.expectFlash 'You are now a member of Open Dirty Dancing Shoes'

      page.fillIn '.comment-form textarea', 'I am new!'
      page.click '.comment-form__submit-button'
      page.expectFlash 'Comment added'

    fit 'allows logged in users to request to join a closed group', ->
      page.loadPath 'view_closed_group_as_non_member'
      page.click '.thread-preview__link'
      page.click '.join-group-button__ask-to-join-group'
      page.click '.membership-request-form__submit-btn'
      page.expectFlash 'You have requested membership to Closed Dirty Dancing Shoes'

  describe 'commenting', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'adds a comment', ->
      page.fillIn '.comment-form textarea', 'hi this is my comment'
      page.click '.comment-form__submit-button'
      page.expectText '.new-comment', 'hi this is my comment'

    xit 'can add emojis', ->
      page.fillIn '.comment-form textarea', 'Here is a dragon!'
      page.click '.comment-form .emoji-picker__toggle'
      page.fillIn '.emoji-picker__search input', 'dragon_face'
      page.click '.emoji-picker__selector:first-child'
      page.sleep(2000)
      page.click '.comment-form__submit-button'
      page.expectText '.thread-item__body','Here is a dragon!'
      page.expectElement '.thread-item__body img'

    fit 'replies to a comment', ->
      page.fillIn '.comment-form textarea', 'original comment right heerrr'
      page.click '.comment-form__submit-button'
      page.click '.action-dock__button--reply_to_comment'
      page.fillIn '.comment-form textarea', 'hi this is my comment'
      page.click '.comment-form__submit-button'
      page.expectText '.activity-card__activity-list-item:last-child', 'in reply to'
      page.expectFlash 'Patrick Swayze notified of reply'

    it 'can react to a comment', ->
      page.expectNoElement '.reaction'
      page.click '.action-dock__button--react',
                 '.emoji-picker__selector:first-child'
      page.expectElement '.reaction'

    it 'mentions a user', ->
      page.fillIn '.comment-form textarea', '@jennifer'
      page.expectText '.mentio-menu', 'Jennifer Grey'
      page.click '.mentio-menu md-menu-item'
      page.click '.comment-form__submit-button'
      page.expectText '.new-comment', '@jennifergrey'

    it 'edits a comment', ->
      page.fillIn '.comment-form textarea', 'original comment right hur'
      page.click '.comment-form__submit-button'
      page.click '.action-dock__button--edit_comment'
      page.fillIn '.edit-comment-form textarea', 'edited comment right thur'
      page.click '.comment-form__submit-btn'
      page.expectText '.new-comment', 'edited comment right thur'

    it 'lets you view comment revision history', ->
      page.fillIn '.comment-form textarea', 'Comment!'
      page.click '.comment-form__submit-button'
      page.click '.action-dock__button--edit_comment'
      page.fillIn '.edit-comment-form textarea', 'Revised comment!'
      page.click  '.comment-form__submit-btn'
      page.click '.action-dock__button--show_history'
      page.expectText '.revision-history-modal__body', 'Revised comment!'
      page.expectText '.revision-history-modal__body', 'Comment!'

    it 'deletes a comment', ->
      page.fillIn '.comment-form textarea', 'original comment right hur'
      page.click '.comment-form__submit-button'
      page.click '.action-dock__button--delete_comment',
                 '.delete-comment-form__delete-button'
      page.expectNoText '.activity-card', 'original comment right thur'
