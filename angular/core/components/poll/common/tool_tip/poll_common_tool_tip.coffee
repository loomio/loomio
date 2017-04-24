angular.module('loomioApp').directive 'pollCommonToolTip', (Session) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/tool_tip/poll_common_tool_tip.html'
  controller: ($scope, Records) ->
    experience_key = $scope.poll.poll_type+"_tool_tip"
    $scope.collapsed = Session.user().hasExperienced(experience_key)

    $scope.hide = ->
      $scope.collapsed = true
      if !Session.user().hasExperienced(experience_key)
        Records.users.saveExperience(experience_key)

    $scope.show = ->
      $scope.collapsed = false
