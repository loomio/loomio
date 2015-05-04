angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope, Records) ->
    $scope.$on 'currentComponent', (el, component) ->
      $scope.selected = component

    $scope.unreadThreadCount = ->
      Records.discussions.forInbox().data().length

    if !$scope.inboxLoaded
      Records.discussions.fetchInbox().then ->
        $scope.inboxLoaded = true
