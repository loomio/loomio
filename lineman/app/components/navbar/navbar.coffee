angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope, Records) ->
    $scope.$on 'currentComponent', (el, component) ->
      $scope.selected = component
      Records.discussions.fetchInbox()

    $scope.unreadThreadCount = ->
      Records.discussions.unread().length

