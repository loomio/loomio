angular.module('loomioApp').directive 'pollCommonSelectGroup', (Session, AbilityService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/select_group/poll_common_select_group.html'
  controller: ($scope) ->
    $scope.groups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canStartPoll(group)
