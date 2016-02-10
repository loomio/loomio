angular.module('loomioApp').factory 'ChoosePlanModal', ->
  templateUrl: 'generated/components/group_page/trial_card/choose_plan_modal/choose_plan_modal.html'
  size: 'choose-plan-modal'
  controller: ($scope, group, ModalService, ConfirmGiftPlanModal, ChargifyService, AppConfig, $window, IntercomService) ->
    $scope.group = group

    $scope.chooseGiftPlan = ->
      ModalService.open ConfirmGiftPlanModal, group: -> $scope.group

    $scope.choosePaidPlan = (kind) ->
      $window.location = "#{AppConfig.chargify.host}#{AppConfig.chargify.plans[kind].path}?#{ChargifyService.encodedParams($scope.group)}"

    $scope.openIntercom = ->
      IntercomService.contactUs()
      $scope.$close()
