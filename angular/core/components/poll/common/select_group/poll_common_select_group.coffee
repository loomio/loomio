angular.module('loomioApp').directive 'pollCommonSelectGroup', (Session, AbilityService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/select_group/poll_common_select_group.html'
  controller: ($scope) ->
    $scope.groups = ->
      Session.user().adminGroups()
