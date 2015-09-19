angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, Records, MessageChannelService, ModalService, DiscussionForm, DeleteThreadForm, ScrollService, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage'})

  handleCommentHash = do ->
    if match = $location.hash().match /comment-(\d+)/
      $location.search().comment = match[1]
      $location.hash('')

  @performScroll = ->
    ScrollService.scrollTo @elementToFocus(), 150
    $rootScope.$broadcast 'triggerVoteForm', $location.search().position if @openVoteModal()

  @openVoteModal = ->
    $location.search().position and
    @discussion.hasActiveProposal() and
    @discussion.activeProposal().key == $location.search().proposal and
    AbilityService.canVoteOn(@discussion.activeProposal())

  @elementToFocus = ->
    if @proposalToFocus or (@discussion.hasActiveProposal() and $location.search().proposal == @discussion.activeProposal().key)
      "#proposal-#{@proposalToFocus.key}"
    else if @commentToFocus
      "#comment-#{@commentToFocus.id}"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @sequenceIdToFocus)
      '.activity-card__last-read-activity'
    else
      '.thread-context'

  @threadElementsLoaded = ->
    @eventsLoaded and @proposalsLoaded

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion
      @group      = @discussion.group()
      @comment    = Records.comments.build(discussionId: @discussion.id)
      if @discussion.hasActiveProposal() and $location.search().proposal == @discussion.activeProposal().key
        @proposalToFocus = @discussion.activeProposal()

      @sequenceIdToFocus = @discussion.lastReadSequenceId # or location hash when we put it back in.

      $rootScope.$broadcast 'currentComponent', { page: 'threadPage'}
      $rootScope.$broadcast 'viewingThread', @discussion
      $rootScope.$broadcast 'setTitle', @discussion.title
      $rootScope.$broadcast 'analyticsSetGroup', @discussion.group()

      MessageChannelService.subscribeToDiscussion(@discussion)

  @init Records.discussions.find $routeParams.key
  Records.discussions.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  $scope.$on 'threadPageEventsLoaded',    (event) =>
    @eventsLoaded = true
    commentId = parseInt($location.search().comment)
    @commentToFocus = Records.comments.find(commentId) unless isNaN(commentId)
    @performScroll() if @proposalsLoaded or !@discussion.anyClosedProposals()
  $scope.$on 'threadPageProposalsLoaded', (event) =>
    @proposalsLoaded = true
    @proposalToFocus = Records.proposals.find $location.search().proposal
    @performScroll() if @eventsLoaded

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editDiscussion = ->
    ModalService.open DiscussionForm, discussion: => @discussion

  @deleteDiscussion = ->
    ModalService.open DeleteThreadForm, discussion: => @discussion

  @showContextMenu = =>
    @canEditDiscussion(@discussion)

  @canStartProposal = ->
    AbilityService.canStartProposal(@discussion)

  @canEditDiscussion = =>
    AbilityService.canEditThread(@discussion)

  @canDeleteDiscussion = =>
    AbilityService.canDeleteThread(@discussion)

  @proposalInView = ($inview) ->
    $rootScope.$broadcast 'proposalInView', $inview

  @proposalButtonInView = ($inview) ->
    $rootScope.$broadcast 'proposalButtonInView', $inview

  return
