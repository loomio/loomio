angular.module('loomioApp').directive 'pollCommonUndecidedUser', (FlashService, LoadingService) ->
  scope: {user: '=', poll: '='}
  templateUrl: 'generated/components/poll/common/undecided/user/poll_common_undecided_user.html'
  controller: ($scope) ->
    $scope.resend = ->
      $scope.user.resend().then ->
        FlashService.success 'common.action.resent'
    LoadingService.applyLoadingFunction $scope, 'resend'

    $scope.remind = ->
      $scope.user.remind($scope.poll).then ->
        FlashService.success 'poll_common_undecided_user.reminder_sent'
    LoadingService.applyLoadingFunction $scope, 'remind'
