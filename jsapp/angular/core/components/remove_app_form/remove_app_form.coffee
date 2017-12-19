angular.module('loomioApp').factory 'RemoveAppForm', ->
  templateUrl: 'generated/components/remove_app_form/remove_app_form.html'
  controller: ($scope, $rootScope, application, FlashService) ->
    $scope.application = application

    $scope.submit = ->
      $scope.application.destroy().then ->
        FlashService.success 'remove_app_form.messages.success', name: $scope.application.name
        $scope.$close()
      , ->
        $rootScope.$broadcast 'pageError', 'cantDestroyApplication', $scope.application
        $scope.$close()
