angular.module('loomioApp').controller 'ThreadPageController', ($routeParams, $location, $rootScope, $document, $modal, Records, MessageChannelService, CurrentUser, DiscussionFormService) ->
  $rootScope.$broadcast('currentComponent', 'threadPage')

  $scope.$on 'threadPageEventsLoaded',    (sequenceId) =>
    @scrollToElement("#sequence-#{sequenceId}") if @focusMode == 'activity'
  $scope.$on 'threadPageProposalsLoaded', (proposalId) =>
    @scrollToElement("#proposal-#{proposalId}") if @focusMode == 'proposal'

  Records.discussions.findOrFetchByKey($routeParams.key).then (discussion) =>
    @discussion = discussion
    $rootScope.$broadcast('setTitle', @discussion.title)
    Records.proposals.fetchByDiscussion @discussion
    Records.votes.fetchMyVotesByDiscussion @discussion
    @group = @discussion.group()
    $rootScope.$broadcast('viewingThread', @discussion)
    MessageChannelService.subscribeTo("/discussion-#{@discussion.key}", @onMessageReceived)
    @setFocusMode()
    @scrollToElement('.thread-context') if @focusMode == 'context'
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

  @scrollToElement = (target) ->
    console.log 'scrolling to ', target
    $document.scrollToElement(angular.element(target), 100)
    angular.element().focus(elem)

  @setFocusMode = ->
    @focusMode = if $location.hash().match(/$proposal-(\d+)^/)
      'proposal'
    else if $scope.discussion.lastSequenceId == 0 or $scope.discussion.reader().lastReadSequenceId == -1
      'context'
    else
      'activity'

  return
