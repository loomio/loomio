angular.module('loomioApp').directive 'pollCommonManageCard', ($translate, Records, Session, FlashService, AbilityService, LmoUrlService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/manage_card/poll_common_manage_card.html'
  controller: ($scope) ->
    $scope.shareableLink = LmoUrlService.poll($scope.poll, {}, absolute: true)
    noGroupOption = Records.groups.build(id: null, fullName: $translate.instant("poll_common_manage_card.no_group_selected"))
    availableGroups = _.filter Session.user().groups(), (group) ->
      AbilityService.canStartPoll(group)

    $scope.groupOptions = ->
      [noGroupOption].concat(availableGroups)

    $scope.hasAvailableGroups = ->
      _.any availableGroups

    $scope.copied = ->
      FlashService.success('common.copied')
