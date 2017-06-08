angular.module('loomioApp').directive 'pollCommonToolTip', (Session) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/tool_tip/poll_common_tool_tip.html'
  controller: ($scope, Records) ->
    experienceKey = $scope.poll.pollType+"_tool_tip"
    $scope.collapsed = Session.user().hasExperienced(experienceKey)

    if !Session.user().hasExperienced(experienceKey)
      Records.users.saveExperience(experienceKey)

    $scope.hide = ->
      $scope.collapsed = true

    $scope.show = ->
      $scope.collapsed = false
