angular.module('loomioApp').factory 'ArchiveGroupForm', ->
  templateUrl: 'generated/components/archive_group_form/archive_group_form.html'
  controller: ($scope, $rootScope, $location, group, FlashService, Records) ->
    $scope.group = group

    $scope.submit = ->
      Records.groups.archive($scope.group).then ->
        FlashService.success 'group_page.messages.archive_group_success'
        $scope.$close()
        $location.path "/dashboard"
      , ->
        $rootScope.$broadcast 'cantArchiveGroup', $scope.group
