angular.module('loomioApp').factory 'LeaveGroupForm', ->
  templateUrl: 'generated/components/leave_group_form/leave_group_form.html'
  controller: ($scope, $location, $rootScope, group, FlashService, CurrentUser) ->
    $scope.group = group

    $scope.submit = ->
      $scope.group.membershipFor(CurrentUser).destroy().then ->
        FlashService.success 'group_page.messages.leave_group_success'
        $scope.$close()
        $location.path "/dashboard"
      , ->
        $rootScope.$broadcast 'pageError', 'cantDestroyMembership', group.membershipFor(CurrentUser)
        $scope.$close()
