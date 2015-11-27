angular.module('loomioApp').factory 'ConfirmGiftPlanModal', ->
  templateUrl: 'generated/components/group_page/trial_card/confirm_gift_plan_modal/confirm_gift_plan_modal.html'
  size: 'confirm-gift-plan-modal'
  controller: ($scope, group, ModalService, ChoosePlanModal, DonationModal) ->
    $scope.group = group

    $scope.choosePlan = ->
      ModalService.open ChoosePlanModal, group: -> $scope.group

    $scope.submit = ->
      $scope.group.remote.postMember(group.key, 'use_gift_subscription').then ->
        ModalService.open DonationModal, group: -> $scope.group
        $scope.$close()
