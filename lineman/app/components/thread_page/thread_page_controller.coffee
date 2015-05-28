angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, Records, MessageChannelService, CurrentUser, DiscussionFormService, ScrollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage'})

  @performScroll = ->
    elementToFocus = @elementToFocus()
    if elementToFocus && !@scrolledAlready
      ScrollService.scrollTo elementToFocus
      @scrolledAlready = true

  @elementToFocus = ->
    if $location.hash().match(/^proposal-\d+$/) and Records.proposals.find(@focusedProposalId)
      "#proposal-#{@focusedProposalId}"
    else if @discussion.lastSequenceId == 0 or @sequenceIdToFocus == -1
      ".thread-context"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @sequenceIdToFocus)
      ".activity-card__last-read-activity"
    else
      false # our record isn't there yet

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion
      @group = @discussion.group()
      @sequenceIdToFocus = @discussion.reader().lastReadSequenceId # or location hash when we put it back in.

      $rootScope.$broadcast 'setTitle', @discussion.title
      $rootScope.$broadcast 'viewingThread', @discussion

      MessageChannelService.subscribeTo "/discussion-#{@discussion.key}"
      @performScroll()

  @init Records.discussions.find $routeParams.key
  Records.discussions.findOrFetchByKey($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  $scope.$on 'threadPageEventsLoaded',    (event) =>
    @eventsLoaded = true
    @performScroll() if @proposalsLoaded or !@discussion.anyClosedProposals()
  $scope.$on 'threadPageProposalsLoaded', (event, proposalId) =>
    @proposalsLoaded = true
    @focusedProposalId = proposalId
    @performScroll()

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editDiscussion = ->
    DiscussionFormService.openEditDiscussionModal(@discussion)

  @showContextMenu = =>
    @canEditDiscussion(@discussion)

  @canEditDiscussion = =>
    CurrentUser.canEditDiscussion(@discussion)

  return
