angular.module('loomioApp').factory 'RevokeAppForm', ->
  templateUrl: 'generated/components/revoke_app_form/revoke_app_form.html'
  controller: ($scope, $rootScope, application, FlashService) ->
    $scope.application = application

    $scope.submit = ->
      $scope.application.revokeAccess().then ->
        FlashService.success 'revoke_app_form.messages.success', name: $scope.application.name
        $scope.$close()
      , ->
        $rootScope.$broadcast 'pageError', 'cantRevokeApplication', $scope.application
        $scope.$close()
