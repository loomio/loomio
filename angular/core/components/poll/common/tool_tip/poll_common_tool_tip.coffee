angular.module('loomioApp').directive 'pollCommonToolTip', (Session) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/tool_tip/poll_common_tool_tip.html'
  controller: ($scope, Records) ->
    experienceKey = $scope.poll.pollType+"_tool_tip"
    $scope.collapsed = Session.user().hasExperienced(experienceKey)

    $scope.hide = ->
      $scope.collapsed = true
      if !Session.user().hasExperienced(experienceKey)
        Records.users.saveExperience(experienceKey)

    $scope.show = ->
      $scope.collapsed = false
