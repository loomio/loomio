angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, Records, MessageChannelService, CurrentUser, DiscussionFormService, ScrollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage'})

  $scope.$on 'threadPageEventsLoaded',    (event, sequenceId) =>
    ScrollService.scrollTo("#sequence-#{sequenceId}") if @focusMode == 'activity'
  $scope.$on 'threadPageProposalsLoaded', (event, proposalId) =>
    ScrollService.scrollTo("#proposal-#{proposalId}") if @focusMode == 'proposal'

  Records.discussions.findOrFetchByKey($routeParams.key).then (discussion) =>
    @discussion = discussion
    $rootScope.$broadcast('setTitle', @discussion.title)
    @group = @discussion.group()
    $rootScope.$broadcast('viewingThread', @discussion)
    MessageChannelService.subscribeTo("/discussion-#{@discussion.key}", @onMessageReceived)
    @setFocusMode()
    ScrollService.scrollTo('.thread-context') if @focusMode == 'context'
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @onMessageReceived = (event) ->
    console.log 'discussion update received', event

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editDiscussion = ->
    DiscussionFormService.openEditDiscussionModal(@discussion)

  @showContextMenu = =>
    @canEditDiscussion(@discussion)

  @canEditDiscussion = =>
    CurrentUser.canEditDiscussion(@discussion)

  @setFocusMode = ->
    @focusMode = if $location.hash().match(/^proposal-\d+$/)
      'proposal'
    else if @discussion.lastSequenceId == 0 or @discussion.reader().lastReadSequenceId == -1
      'context'
    else
      'activity'

  return
