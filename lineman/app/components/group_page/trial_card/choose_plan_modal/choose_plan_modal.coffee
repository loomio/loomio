angular.module('loomioApp').factory 'ChoosePlanModal', ->
  templateUrl: 'generated/components/group_page/trial_card/choose_plan_modal/choose_plan_modal.html'
  size: 'choose-plan-modal'
  controller: ($scope, group, ModalService, ConfirmGiftPlanModal, CurrentUser, AppConfig, $window) ->
    $scope.group = group

    $scope.chooseGiftPlan = ->
      ModalService.open ConfirmGiftPlanModal, group: -> $scope.group

    $scope.choosePaidPlan = (kind) ->
      $window.location = "#{AppConfig.chargify.host}#{AppConfig.chargify.plans[kind].path}?#{encodedChargifyParams()}"

    $scope.openIntercom = ->
      $window.Intercom.public_api.showNewMessage()
      $scope.$close()

    encodedChargifyParams = ->
      params =
        first_name: CurrentUser.firstName()
        last_name: CurrentUser.lastName()
        email: CurrentUser.email
        organization: $scope.group.name
        reference: $scope.group.key

      _.map(_.keys(params), (key) ->
        encodeURIComponent(key) + "=" + encodeURIComponent(params[key])
      ).join('&')
