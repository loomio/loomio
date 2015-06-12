angular.module('loomioApp').factory 'StartGroupForm', ->
  templateUrl: 'generated/components/start_group_form/start_group_form.html'
  controller: ($scope, $rootScope, $location, group, Records, LmoUrlService) ->
    $scope.group = group

    $scope.submit = ->
      $scope.group.save().then (response) ->
        $scope.$close()
        $location.path LmoUrlService.group Records.groups.find(response.groups[0].id)
        $rootScope.$broadcast 'newGroupCreated'
      , ->
        $rootScope.$broadcast 'pageError', 'cantCreateGroup', $scope.group
