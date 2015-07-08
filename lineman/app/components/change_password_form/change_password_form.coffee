angular.module('loomioApp').factory 'ChangePasswordForm', ->
  templateUrl: 'generated/components/change_password_form/change_password_form.html'
  controller: ($scope, $rootScope, CurrentUser, Records, FlashService) ->
    $scope.user = CurrentUser.clone()

    $scope.submit = ->
      $scope.isDisabled = true
      Records.users.changePassword($scope.user).then ->
        $scope.isDisabled = false
        FlashService.success('profile_page.messages.password_changed')
        $scope.$close()
      , (response) ->
        $scope.isDisabled = false
        if response.status == 422
          $scope.user.setErrors response.data.errors
        else
          $rootScope.$broadcast 'pageError', response
