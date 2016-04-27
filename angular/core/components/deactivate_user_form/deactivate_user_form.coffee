angular.module('loomioApp').factory 'DeactivateUserForm', ->
  templateUrl: 'generated/components/deactivate_user_form/deactivate_user_form.html'
  controller: ($scope, $rootScope, $window, User, Records, FormService) ->
    $scope.user = User.current().clone()

    $scope.submit = FormService.submit $scope, $scope.user,
      submitFn: Records.users.deactivate
      successCallback: -> $window.location.reload()
