Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'addCommentPanel', ($timeout, ModalService, AuthModal, ScrollService) ->
  scope: {eventWindow: '=', parentEvent: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/add_comment_panel/add_comment_panel.html'
  controller: ($scope) ->
    $scope.discussion = $scope.eventWindow.discussion
    $scope.actor = Session.user()
    $scope.isLoggedIn = -> AbilityService.isLoggedIn()
    $scope.signIn = -> ModalService.open 'AuthModal'
    $scope.canAddComment = -> AbilityService.canAddComment($scope.discussion)

    $scope.show = ($scope.parentEvent == $scope.discussion.createdEvent())
    $scope.close = -> $scope.show = false
    $scope.isReply = false

    $scope.indent = -> $scope.eventWindow.useNesting && $scope.isReply

    $scope.$on 'replyToEvent', (e, event) ->
      # if we're in nesting and we're the correct reply OR we're in chronoglogical, always accept parentComment
      if (!$scope.eventWindow.useNesting) || ($scope.parentEvent.id == event.id)
        $scope.show = true
        $timeout ->
          $scope.isReply = true
          $scope.$broadcast 'setParentComment', event.model()

      ScrollService.scrollTo('.add-comment-panel textarea', {bottom: true, offset: 200})

    $scope.$on 'commentSaved', ->
      if $scope.parentEvent == $scope.discussion.createdEvent()
        $scope.parentComment = null
      else
        $scope.close()
