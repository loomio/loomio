angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, $window, $timeout, Records, KeyEventService, ModalService, ScrollService, AbilityService, Session, PaginationService, LmoUrlService,  PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage', skipScroll: true })

  # if we get given a comment id, then hard refresh after seeking it's sequenceId
  # sorry everyone, we'll stop using hardcoded notification.urls some day soon
  requestedCommentId = ->
    parseInt($routeParams.comment or $location.search().comment)

  if requestedCommentId()
    Records.events.fetch
      params:
        discussion_id: $routeParams.key
        comment_id: requestedCommentId()
        per: 1
    .then ->
      event = Records.events.find(kind: "new_comment", eventableId: requestedCommentId())[0]
      $window.location.href = "/d/#{$routeParams.key}/?from=#{event.sequenceId}";

  chompRequestedSequenceId = ->
    requestedSequenceId = parseInt($location.search().from)
    $location.search('from', null)
    requestedSequenceId

  @nested = ->
    @discussion.group().features.nested_comments

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion
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
