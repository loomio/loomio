describe 'Activity Items', ->

  threadHelper = require './helpers/thread_helper.coffee'
  proposalsHelper = require './helpers/proposals_helper.coffee'

  beforeEach ->
    threadHelper.loadWithActiveProposal()
    threadHelper.editThreadTitle()
    threadHelper.editThreadDescription()
    threadHelper.editThreadTitleAndDescription()
    proposalsHelper.editProposalName()
    proposalsHelper.editProposalDescription()
    proposalsHelper.editProposalNameAndDescription()

  it 'dispays thread and proposal activity items correctly', ->
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the thread title: Edited thread title')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the thread description')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the thread title and description')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the proposal title: Edited proposal title')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the proposal description')
    expect(threadHelper.activityItemList()).toContain('Patrick Swayze updated the proposal title and description')
