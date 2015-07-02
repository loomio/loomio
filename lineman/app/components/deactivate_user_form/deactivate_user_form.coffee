angular.module('loomioApp').factory 'DeactivateUserForm', ->
  templateUrl: 'generated/components/deactivate_user_form/deactivate_user_form.html'
  controller: ($scope, $rootScope, $window, CurrentUser, Records) ->
    $scope.user = CurrentUser.clone()

    $scope.submit = ->
      $scope.isDisabled = true
      Records.users.deactivate($scope.user).then ->
        $scope.isDisabled = false
        $window.location.reload()
      , ->
        $scope.isDisabled = false
        $rootScope.$broadcast 'pageError', 'cantDeactivateUser', $scope.user
