angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, $window, $timeout, Records, KeyEventService, ModalService, ScrollService, AbilityService, Session, PaginationService, LmoUrlService,  PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage', skipScroll: true })

  requestedCommentId = ->
    parseInt($routeParams.comment or $location.search().comment)

  if requestedCommentId()
    Records.events.fetch
      path: 'comment'
      params:
        discussion_id: $routeParams.key
        comment_id: requestedCommentId()
    .then =>
      comment = Records.comments.find(requestedCommentId())
      @discussion = comment.discussion()
      @discussion.requestedSequenceId = comment.createdEvent().sequenceId
      $scope.$broadcast 'initActivityCard'

  chompRequestedSequenceId = ->
    requestedSequenceId = parseInt($location.search().from || $routeParams.sequence_id)
    $location.search('from', null)
    requestedSequenceId

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion
      @discussion.markAsSeen()
      @discussion.requestedSequenceId = chompRequestedSequenceId()

      @pageWindow = PaginationService.windowFor
        current:  @discussion.requestedSequenceId || @discussion.firstSequenceId()
        min:      @discussion.firstSequenceId()
        max:      @discussion.lastSequenceId()
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

  $scope.$on 'threadPageScrollToSelector', (e, selector) =>
    ScrollService.scrollTo selector, offset: 150

  checkInView = ->
    angular.element(window).triggerHandler('checkInView')

  KeyEventService.registerKeyEvent $scope, 'pressedUpArrow', checkInView
  KeyEventService.registerKeyEvent $scope, 'pressedDownArrow', checkInView

  return
