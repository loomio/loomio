angular.module('loomioApp').factory 'ChangePasswordForm', ->
  templateUrl: 'generated/components/change_password_form/change_password_form.html'
  controller: ($scope, $rootScope, CurrentUser, Records, FormService) ->
    $scope.user = CurrentUser.clone()

    $scope.submit = FormService.submit $scope, $scope.user,
      submitFn: Records.users.changePassword
      flashSuccess: 'profile_page.messages.password_changed'
