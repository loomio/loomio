angular.module('loomioApp').factory 'DeactivateUserForm', ->
  templateUrl: 'generated/components/deactivate_user_form/deactivate_user_form.html'
  controller: ($scope, $rootScope, $location, CurrentUser, Records, FlashService) ->
    $scope.user = CurrentUser.clone()

    $scope.submit = ->
      $scope.isDisabled = true
      Records.users.deactivate($scope.user).then ->
        $scope.isDisabled = false
        FlashService.success('profile_page.messages.user_deactivated')
        $location.path "/"
      , ->
        $scope.isDisabled = false
        $rootScope.$broadcast 'pageError', 'cantDeactivateUser', $scope.user
