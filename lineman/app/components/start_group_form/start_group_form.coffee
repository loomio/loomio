angular.module('loomioApp').factory 'StartGroupForm', ->
  templateUrl: 'generated/components/start_group_form/start_group_form.html'
  controller: ($scope, $rootScope, $location, group, Records, FormService) ->
    $scope.group = group

    $scope.submit = FormService.submit $scope, $scope.group,
      successCallback: (response) ->
        $location.path "/g/#{response.groups[0].key}"
        $rootScope.$broadcast 'newGroupCreated'
