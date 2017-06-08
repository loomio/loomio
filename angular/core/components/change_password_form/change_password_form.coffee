angular.module('loomioApp').factory 'ChangePasswordForm', ->
  templateUrl: 'generated/components/change_password_form/change_password_form.html'
  controller: ($scope, $rootScope, Session, Records, AuthService) ->
    $scope.user = Session.user().clone()

    $scope.submit = ->
      $scope.processing = true
      AuthService.forgotPassword($scope.user).then ->
        $scope.user.sentPasswordLink = true
      .finally ->
        $scope.processing = false
