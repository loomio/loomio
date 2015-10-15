angular.module('loomioApp').directive 'trialCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/trial_card/trial_card.html'
  replace: true
  controller: ($scope, ModalService, ChoosePlanModal) ->

    $scope.isExpired = ->
      moment().isAfter($scope.group.subscriptionExpiresAt)

    $scope.choosePlan = ->
      ModalService.open ChoosePlanModal, group: -> $scope.group
