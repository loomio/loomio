angular.module('loomioApp').directive 'trialCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/trial_card/trial_card.html'
  replace: true
  controller: ($scope, ModalService, ChoosePlanModal, AbilityService, AppConfig, User) ->

    $scope.show = ->
      $scope.group.subscriptionKind == 'trial' and
      User.current().isAdminOf($scope.group) and
      AppConfig.chargify?

    $scope.isExpired = ->
      moment().isAfter($scope.group.subscriptionExpiresAt)

    $scope.choosePlan = ->
      ModalService.open ChoosePlanModal, group: -> $scope.group
