angular.module('loomioApp').directive 'pollCommonShareGroupForm', (Session, FormService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/group_form/poll_common_share_group_form.html'
  controller: ($scope) ->
    $scope.groups = ->
      Session.user().adminGroups()

    $scope.currentGroupId = $scope.poll.groupId

    $scope.submit = FormService.submit $scope, $scope.poll,
      flashSuccess: 'poll_common_share_form.group_updated'
      prepareFn: ->
        $scope.poll.groupId = $scope.currentGroupId
