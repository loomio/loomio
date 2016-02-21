angular.module('loomioApp').factory 'RemoveOauthApplicationForm', ->
  templateUrl: 'generated/components/remove_oauth_application_form/remove_oauth_application_form.html'
  controller: ($scope, $rootScope, application, FlashService) ->
    $scope.application = application

    $scope.submit = ->
      $scope.application.destroy().then ->
        FlashService.success 'remove_oauth_application_form.messages.success', name: $scope.application.name
        $scope.$close()
      , ->
        $rootScope.$broadcast 'pageError', 'cantDestroyApplication', $scope.application
        $scope.$close()
