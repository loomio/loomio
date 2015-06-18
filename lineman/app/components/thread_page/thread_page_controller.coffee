angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, Records, MessageChannelService, ModalService, DiscussionForm, ScrollService, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage'})

  @performScroll = ->
    if (elementToFocus = @elementToFocus()) && !@scrolledAlready
      ScrollService.scrollTo elementToFocus
      @scrolledAlready = true

  @elementToFocus = ->
    if proposal = Records.proposals.find($location.search().proposal)
      if (position = $location.search().position) and AbilityService.canVoteOn(proposal)
        $rootScope.$broadcast 'triggerVoteForm', position
      "#proposal-#{proposal.key}"
    else if @discussion.lastSequenceId == 0 or @sequenceIdToFocus == -1
      ".thread-context"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @sequenceIdToFocus)
      ".activity-card__last-read-activity"
    else
      false # our record isn't there yet

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion
      @group      = @discussion.group()
      @comment    = Records.comments.build(discussion_id: @discussion.id)

      @sequenceIdToFocus = @discussion.reader().lastReadSequenceId # or location hash when we put it back in.

      $rootScope.$broadcast 'currentComponent', { page: 'threadPage'}
      $rootScope.$broadcast 'viewingThread', @discussion
      $rootScope.$broadcast 'setTitle', @discussion.title

      MessageChannelService.subscribeTo "/discussion-#{@discussion.key}"
      @performScroll()

  @init Records.discussions.find $routeParams.key
  Records.discussions.findOrFetchByKey($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  $scope.$on 'threadPageEventsLoaded',    (event) =>
    @eventsLoaded = true
    @performScroll() if @proposalsLoaded or !@discussion.anyClosedProposals()
  $scope.$on 'threadPageProposalsLoaded', (event) =>
    @proposalsLoaded = true
    @performScroll()

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editDiscussion = ->
    ModalService.open DiscussionForm, discussion: => @discussion

  @showContextMenu = =>
    @canEditDiscussion(@discussion)

  @canStartProposal = ->
    AbilityService.canStartProposal(@discussion)

  @canEditDiscussion = =>
    AbilityService.canEditThread(@discussion)

  @proposalInView = ($inview) ->
    $rootScope.$broadcast 'proposalInView', $inview

  @proposalButtonInView = ($inview) ->
    $rootScope.$broadcast 'proposalButtonInView', $inview

  return
