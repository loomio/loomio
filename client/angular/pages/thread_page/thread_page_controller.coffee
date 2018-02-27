LmoUrlService     = require 'shared/services/lmo_url_service.coffee'
Session           = require 'shared/services/session.coffee'
Records           = require 'shared/services/records.coffee'
EventBus          = require 'shared/services/event_bus.coffee'
AbilityService    = require 'shared/services/ability_service.coffee'
PaginationService = require 'shared/services/pagination_service.coffee'
LmoUrlService     = require 'shared/services/lmo_url_service.coffee'

{ scrollTo }         = require 'shared/helpers/layout.coffee'
{ registerKeyEvent } = require 'shared/helpers/keyboard.coffee'

$controller = ($scope, $routeParams, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'threadPage', skipScroll: true, skipForceSignIn: true }

  requestedCommentId = ->
    parseInt($routeParams.comment or LmoUrlService.params().comment)

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
      EventBus.broadcast $scope, 'initActivityCard'

  chompRequestedSequenceId = ->
    requestedSequenceId = parseInt(LmoUrlService.params().from || $routeParams.sequence_id)
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
        skipForceSignIn: true
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

$controller.$inject = ['$scope', '$routeParams', '$rootScope']
angular.module('loomioApp').controller 'ThreadPageController', $controller
