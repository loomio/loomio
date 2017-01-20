angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, $window, $timeout, Records, MessageChannelService, KeyEventService, ModalService, ScrollService, AbilityService, Session, PaginationService, LmoUrlService, TranslationService, ProposalOutcomeForm, PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage', skipScroll: true })

  @requestedProposalKey = $routeParams.proposal or $location.search().proposal
  @requestedCommentId   = parseInt($routeParams.comment or $location.search().comment)

  handleCommentHash = do ->
    if match = $location.hash().match /comment-(\d+)/
      $location.search().comment = match[1]
      $location.hash('')

  @performScroll = ->
    ScrollService.scrollTo @elementToFocus(), 150
    $rootScope.$broadcast 'triggerVoteForm', $location.search().position if @openVoteModal()
    (ModalService.open ProposalOutcomeForm, proposal: => @proposal) if @openOutcomeModal()
    $location.url($location.path())

  @openVoteModal = ->
    $location.search().position and
    @discussion.hasActiveProposal() and
    @discussion.activeProposal().key == ($routeParams.proposal or $location.search().proposal or $routeParams.proposal) and
    AbilityService.canVoteOn(@discussion.activeProposal())

  @openOutcomeModal = ->
    AbilityService.canCreateOutcomeFor(@proposal) and
    $routeParams.outcome? and
    (delete $routeParams.outcome)

  @elementToFocus = ->
    if @proposal
      "#proposal-#{@proposal.key}"
    else if @comment
      "#comment-#{@comment.id}"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @sequenceIdToFocus)
      '.activity-card__last-read-activity'
    else
      '.context-panel'

  @threadElementsLoaded = ->
    @eventsLoaded and @proposalsLoaded


  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion

      # use new poll functionality
      if @usePolls = PollService.usePollsFor(@discussion)
        Records.polls.fetchByDiscussion(@discussion.key)
        Records.stances.fetchMyStancesByDiscussion(@discussion.key)

      @sequenceIdToFocus = parseInt($location.search().from or @discussion.lastReadSequenceId)

      @pageWindow = PaginationService.windowFor
        current:  @sequenceIdToFocus
        min:      @discussion.firstSequenceId
        max:      @discussion.lastSequenceId
        pageType: 'activityItems'

      $rootScope.$broadcast 'viewingThread', @discussion
      $rootScope.$broadcast 'setTitle', @discussion.title
      $rootScope.$broadcast 'analyticsSetGroup', @discussion.group()
      $rootScope.$broadcast 'currentComponent',
        page: 'threadPage'
        group: @discussion.group()
        links:
          canonical:   LmoUrlService.discussion(@discussion, {}, absolute: true)
          rss:         LmoUrlService.discussion(@discussion) + '.xml' if !@discussion.private
          prev:        LmoUrlService.discussion(@discussion, from: @pageWindow.prev) if @pageWindow.prev?
          next:        LmoUrlService.discussion(@discussion, from: @pageWindow.next) if @pageWindow.next?
        skipScroll: true

  @init Records.discussions.find $routeParams.key
  Records.discussions.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  $scope.$on 'threadPageEventsLoaded',    (e, event) =>
    $window.location.reload() if @discussion.requireReloadFor(event)
    @eventsLoaded = true
    @comment = Records.comments.find(@requestedCommentId) unless isNaN(@requestedCommentId)
    @performScroll() if @proposalsLoaded or !@discussion.anyClosedProposals()
  $scope.$on 'threadPageProposalsLoaded', (event) =>
    @proposalsLoaded = true
    @proposal = Records.proposals.find(@requestedProposalKey)
    $rootScope.$broadcast 'setSelectedProposal', @proposal
    @performScroll() if @eventsLoaded

  @hasClosedPolls = ->
    _.any @discussion.closedPolls()

  @canStartProposal = ->
    @eventsLoaded && AbilityService.canStartProposal(@discussion)

  @canViewMemberships = ->
    @eventsLoaded && AbilityService.canViewMemberships(@discussion.group())

  @proposalInView = ($inview) ->
    $rootScope.$broadcast 'proposalInView', $inview

  @proposalButtonInView = ($inview) ->
    $rootScope.$broadcast 'proposalButtonInView', $inview

  TranslationService.listenForTranslations($scope, @)

  checkInView = ->
    angular.element(window).triggerHandler('checkInView')

  KeyEventService.registerKeyEvent $scope, 'pressedUpArrow', checkInView
  KeyEventService.registerKeyEvent $scope, 'pressedDownArrow', checkInView

  return
