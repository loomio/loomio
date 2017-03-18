describe 'Activity Items', ->

  threadHelper = require './helpers/thread_helper.coffee'
  proposalsHelper = require './helpers/proposals_helper.coffee'
  page = require './helpers/page_helper.coffee'

  it 'dispays thread activity items correctly', ->
    page.loadPath('setup_proposal', 60000)
    threadHelper.editThreadTitle()
    threadHelper.editThreadContext()
    threadHelper.editThreadTitleAndContext()
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the thread title: Edited thread title')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the thread context')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the thread title and context')
  , 100*1000

  it 'displays proposal activity items correctly', ->
    page.loadPath('setup_proposal', 60000)
    proposalsHelper.editProposalName()
    proposalsHelper.editProposalDescription()
    proposalsHelper.editProposalNameAndDescription()
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the proposal title: Edited proposal title')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the proposal description')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the proposal title and description')
  , 100*1000
