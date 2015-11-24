describe 'Discussion Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  discussionForm = require './helpers/discussion_form_helper.coffee'
  threadPage = require './helpers/thread_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'

  beforeEach ->
    threadPage.load()

  describe 'edit thread', ->
    it 'lets you edit title and context', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('better title')
      discussionForm.fillInDescription("improved description")
      discussionForm.clickUpdate()
      expect(threadPage.discussionTitle()).toContain('better title')
      expect(threadPage.discussionTitle()).toContain("improved description")

    it 'does not store cancelled thread info', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('dumb title')
      discussionForm.fillInDescription("rubbish description")
      discussionForm.clickCancel()
      threadPage.openEditThreadForm()
      expect(discussionForm.titleField().getText()).not.toContain('dumb title')
      expect(discussionForm.descriptionField().getText()).not.toContain('rubbish description')
      expect(discussionForm.titleField().getText()).not.toContain('dumb title')
      expect(discussionForm.descriptionField().getText()).not.toContain('rubbish description')

  describe 'move thread', ->
    it 'lets you move a thread', ->
      threadPage.loadWithMultipleDiscussions()
      threadPage.moveThread('Point Break')
      expect(threadPage.groupTitle()).toContain('Point Break')
      expect(flashHelper.flashMessage()).toContain('Thread has been moved to Point Break')

  describe 'delete thread', ->

    it 'lets coordinators and thread authors delete threads', ->
      threadPage.openThreadOptionsDropdown()
      threadPage.selectDeleteThreadOption()
      threadPage.confirmThreadDeletion()
      expect(flashHelper.flashMessage()).toContain('Thread deleted')
      expect(groupsHelper.groupName().isPresent()).toBe(true)
      expect(groupsHelper.groupPage()).not.toContain('What star sign are you?')

  describe 'changing thread volume', ->

    it 'lets you change thread notification volume', ->
      expect(threadPage.threadVolumeCard()).toContain('Email proposals')
      threadPage.clickChangeInThreadVolumeCard()
      threadPage.changeThreadVolumeToLoud()
      threadPage.submitChangeVolumeForm()
      expect(threadPage.threadVolumeCard()).toContain('Email everything')

  it 'adds a comment', ->
    threadPage.addComment('hi this is my comment')
    expect(threadPage.mostRecentComment()).toContain('hi this is my comment')

  it 'replies to a comment', ->
    threadPage.addComment('original comment right heerrr')
    threadPage.replyLinkOnMostRecentComment().click()
    threadPage.addComment('hi this is my comment')
    expect(threadPage.inReplyToOnMostRecentComment()).toContain('in reply to')
    expect(flashHelper.flashMessage()).toContain('Patrick Swayze notified of reply')

  it 'likes a comment', ->
    threadPage.addComment('hi')
    threadPage.likeLinkOnMostRecentComment().click()
    expect(threadPage.likedByOnMostRecentComment()).toContain('You like this.')

  it 'mentions a user', ->
    threadPage.enterCommentText('@jennifer')
    expect(threadPage.mentionList().getText()).toContain('Jennifer Grey')
    threadPage.firstMentionOption().click()
    threadPage.submitComment()
    expect(threadPage.mostRecentComment()).toContain('@jennifergrey')

  it 'edits a comment', ->
    threadPage.addComment('original comment right hur')
    threadPage.clickThreadItemOptionsButton()
    threadPage.selectEditCommentOption()
    threadPage.editCommentText('edited comment right thur')
    threadPage.submitEditedComment()
    expect(threadPage.mostRecentComment()).toContain('edited comment right thur')

  it 'deletes a comment', ->
    threadPage.addComment('original comment right hur')
    threadPage.clickThreadItemOptionsButton()
    threadPage.selectDeleteCommentOption()
    threadPage.confirmCommentDeletion()
    expect(threadPage.activityPanel()).not.toContain('original comment right thur')

  it 'hides member actions from visitors', ->
    threadPage.loadWithPublicContent()
    expect(threadPage.commentForm().isPresent()).toBe(false)
    expect(threadPage.threadOptionsDropdown().isPresent()).toBe(false)
    expect(threadPage.volumeOptions().isPresent()).toBe(false)
