angular.module('loomioApp').directive 'pollCommonManageCard', (Session, FlashService, AbilityService, LmoUrlService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/manage_card/poll_common_manage_card.html'
  controller: ($scope) ->
    $scope.shareableLink = LmoUrlService.poll($scope.poll, {}, absolute: true)

    $scope.availableGroups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canStartPoll(group)

    $scope.hasAvailableGroups = ->
      _.any $scope.availableGroups()

    $scope.copied = ->
      FlashService.success('common.copied')
