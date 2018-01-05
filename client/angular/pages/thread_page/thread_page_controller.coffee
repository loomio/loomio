LmoUrlService     = require 'shared/services/lmo_url_service.coffee'
Session           = require 'shared/services/session.coffee'
Records           = require 'shared/services/records.coffee'
EventBus          = require 'shared/services/event_bus.coffee'
AbilityService    = require 'shared/services/ability_service.coffee'
PaginationService = require 'shared/services/pagination_service.coffee'
LmoUrlService     = require 'shared/services/lmo_url_service.coffee'

{ scrollTo }         = require 'shared/helpers/window.coffee'
{ registerKeyEvent } = require 'angular/helpers/keyboard.coffee'

$controller = ($scope, $routeParams, $rootScope, $timeout) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'threadPage', skipScroll: true }

  # if we get given a comment id, then hard refresh after seeking it's sequenceId
  # sorry everyone, we'll stop using hardcoded notification.urls some day soon
  requestedCommentId = ->
    parseInt($routeParams.comment or LmoUrlService.params().comment)

  if requestedCommentId()
    Records.events.fetch
      params:
        discussion_id: $routeParams.key
        comment_id: requestedCommentId()
        per: 1
    .then =>
      comment = Records.comments.find(requestedCommentId())
      @discussion = comment.discussion()
      @discussion.requestedSequenceId = comment.createdEvent().sequenceId
      EventBus.broadcast $scope, 'initActivityCard'

  chompRequestedSequenceId = ->
    requestedSequenceId = parseInt(LmoUrlService.params().from)
    LmoUrlService.params('from', null)
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

      EventBus.broadcast $rootScope, 'currentComponent',
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

  Records.discussions.findOrFetchById($routeParams.key, {}, true).then @init, (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  EventBus.listen $scope, 'threadPageScrollToSelector', (e, selector) =>
    scrollTo selector, offset: 150

  checkInView = ->
    angular.element(window).triggerHandler('checkInView')

  registerKeyEvent $scope, 'pressedUpArrow', checkInView
  registerKeyEvent $scope, 'pressedDownArrow', checkInView

  return

$controller.$inject = ['$scope', '$routeParams', '$rootScope', '$timeout']
angular.module('loomioApp').controller 'ThreadPageController', $controller
