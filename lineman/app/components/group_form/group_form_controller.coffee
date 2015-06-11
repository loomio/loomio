angular.module('loomioApp').controller 'GroupFormController', ($scope, $rootScope, $modalInstance, $location, group, Records, LmoUrlService) ->
  $scope.group = group or Records.groups.initialize()

  $scope.submit = ->
    $scope.group.save().then (response) ->
      $location.path LmoUrlService.group Records.groups.find(response.groups[0].id)
      $modalInstance.dismiss 'success'
      $rootScope.$broadcast 'newGroupCreated'
    , ->
      $rootScope.$broadcast 'pageError', 'cantCreateGroup', $scope.group
