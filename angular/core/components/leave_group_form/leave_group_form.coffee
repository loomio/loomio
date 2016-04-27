angular.module('loomioApp').factory 'LeaveGroupForm', ->
  templateUrl: 'generated/components/leave_group_form/leave_group_form.html'
  controller: ($scope, $location, $rootScope, group, FormService, User, AbilityService) ->
    $scope.group = group
    $scope.membership = $scope.group.membershipFor(User.current())

    $scope.submit = FormService.submit $scope, $scope.group,
      submitFn: $scope.membership.destroy
      flashSuccess: 'group_page.messages.leave_group_success'
      successCallback: ->
        $rootScope.$broadcast 'currentUserMembershipsLoaded'
        $location.path '/dashboard'

    $scope.canLeaveGroup = ->
      AbilityService.canRemoveMembership($scope.membership)
