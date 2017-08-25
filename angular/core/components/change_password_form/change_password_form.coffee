angular.module('loomioApp').factory 'ChangePasswordForm', (Session, Records, FormService) ->
  templateUrl: 'generated/components/change_password_form/change_password_form.html'
  controller: ($scope) ->
    $scope.user = Session.user().clone()

    actionName = if $scope.user.hasPassword then 'password_changed' else 'password_set'

    $scope.submit = FormService.submit $scope, $scope.user,
      submitFn: Records.users.updateProfile
      flashSuccess: "change_password_form.#{actionName}"
