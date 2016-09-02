angular.module('loomioApp').directive 'upgradePlanCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/upgrade_plan_card/upgrade_plan_card.html'
  replace: true
  controller: ($scope, $window, AppConfig, Session, ModalService, ChoosePlanModal) ->

    $scope.show = ->
      Session.user().isMemberOf($scope.group) and
      $scope.group.subscriptionKind == 'gift' and
      AppConfig.chargify?

    $scope.segmentA = ->
      parseInt(($scope.group.segmentSeed).toString()[0])%2 == 0

    $scope.openUpgradeModal = ->
      ModalService.open ChoosePlanModal, group: -> $scope.group
