angular.module('loomioApp').factory 'OnlyCoordinatorModal', ->
  templateUrl: 'generated/components/only_coordinator_modal/only_coordinator_modal.html'
  controller: ($scope, $location, Session, LmoUrlService) ->

    $scope.groups = ->
      _.filter Session.user().groups(), (group) ->
        _.contains(group.adminIds(), Session.user().id) and
        !group.hasMultipleAdmins

    $scope.redirectToGroup = (group) ->
      $location.path LmoUrlService.group(group)
      $scope.$close()
