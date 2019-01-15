FlashService   = require 'shared/services/flash_service'
AbilityService = require 'shared/services/ability_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'pollCommonUndecidedUser', ->
  scope: {user: '=', poll: '='}
  template: require('./poll_common_undecided_user.haml')
  controller: ['$scope', ($scope) ->
    $scope.canAdministerPoll = ->
      AbilityService.canAdministerPoll($scope.poll)

    $scope.remind = ->
      $scope.user.remind($scope.poll).then ->
        FlashService.success 'poll_common_undecided_user.reminder_sent'
    applyLoadingFunction $scope, 'remind'
  ]
