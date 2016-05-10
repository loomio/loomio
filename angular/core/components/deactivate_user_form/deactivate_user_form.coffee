angular.module('loomioApp').factory 'DeactivateUserForm', ->
  templateUrl: 'generated/components/deactivate_user_form/deactivate_user_form.html'
  controller: ($scope, $rootScope, $window, Session, Records, FormService) ->
    $scope.user = Session.user().clone()

    $scope.submit = FormService.submit $scope, $scope.user,
      submitFn: Records.users.deactivate
      successCallback: -> $window.location.reload()
