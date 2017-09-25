angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, $window, $timeout, Records, KeyEventService, ModalService, ScrollService, AbilityService, Session, PaginationService, LmoUrlService,  PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage', skipScroll: true })

  @requestedCommentId   = parseInt($routeParams.comment or $location.search().comment)

  handleCommentHash = do ->
    if match = $location.hash().match /comment-(\d+)/
      $location.search().comment = match[1]
      $location.hash('')

  @performScroll = ->
    ScrollService.scrollTo @elementToFocus(), offset: 150
    $location.url($location.path())

  @elementToFocus = ->
    if @comment
      "#comment-#{@comment.id}"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @sequenceIdToFocus)
      "#sequence-#{@sequenceIdToFocus}"
    else
      '.context-panel'

  @threadElementsLoaded = ->
    @eventsLoaded

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion

      @sequenceIdToFocus = parseInt($location.search().from or @discussion.lastReadSequenceId)

      @pageWindow = PaginationService.windowFor
        current:  @sequenceIdToFocus
        min:      @discussion.firstSequenceId
        max:      @discussion.lastSequenceId
        pageType: 'activityItems'

      $rootScope.$broadcast 'currentComponent',
        title: @discussion.title
        page: 'threadPage'
        group: @discussion.group()
        discussion: @discussion
        links:
          canonical:   LmoUrlService.discussion(@discussion, {}, absolute: true)
          rss:         LmoUrlService.discussion(@discussion) + '.xml' if !@discussion.private
          prev:        LmoUrlService.discussion(@discussion, from: @pageWindow.prev) if @pageWindow.prev?
          next:        LmoUrlService.discussion(@discussion, from: @pageWindow.next) if @pageWindow.next?
        skipScroll: true

  @init Records.discussions.find $routeParams.key
  Records.discussions.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  $scope.$on 'threadPageEventsLoaded', (e, event) =>
    $window.location.reload() if @discussion.requireReloadFor(event)
    @eventsLoaded = true
    @comment = Records.comments.find(@requestedCommentId) unless isNaN(@requestedCommentId)
    @performScroll()

  @hasClosedPolls = ->
    _.any @discussion.closedPolls()

  @canViewMemberships = ->
    @eventsLoaded && AbilityService.canViewMemberships(@discussion.group())

  checkInView = ->
    angular.element(window).triggerHandler('checkInView')

  @canStartPoll = ->
    AbilityService.canStartPoll(@discussion.group()) or
    AbilityService.canStartPoll(@discussion.guestGroup())

  KeyEventService.registerKeyEvent $scope, 'pressedUpArrow', checkInView
  KeyEventService.registerKeyEvent $scope, 'pressedDownArrow', checkInView

  return
