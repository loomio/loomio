angular.module('loomioApp').factory 'ConfirmGiftPlanModal', ->
  templateUrl: 'generated/components/group_page/trial_card/confirm_gift_plan_modal/confirm_gift_plan_modal.html'
  size: 'confirm-gift-plan-modal'
  controller: ($scope, group) ->
    $scope.group = group

    $scope.submit = ->
      $scope.group.remote.postMember(group.key, 'use_gift_subscription').then ->
        $scope.$close()
