{ applyLoadingFunction } = require 'angular/helpers/loading.coffee'

angular.module('loomioApp').directive 'pollCommonUndecidedUser', (FlashService) ->
  scope: {user: '=', poll: '='}
  templateUrl: 'generated/components/poll/common/undecided/user/poll_common_undecided_user.html'
  controller: ($scope) ->
    $scope.resend = ->
      $scope.user.resend().then ->
        FlashService.success 'common.action.resent'
    applyLoadingFunction($scope, 'resend')

    $scope.remind = ->
      $scope.user.remind($scope.poll).then ->
        FlashService.success 'poll_common_undecided_user.reminder_sent'
    applyLoadingFunction $scope, 'remind'
