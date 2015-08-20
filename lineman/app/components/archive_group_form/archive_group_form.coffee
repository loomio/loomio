angular.module('loomioApp').factory 'ArchiveGroupForm', ->
  templateUrl: 'generated/components/archive_group_form/archive_group_form.html'
  controller: ($scope, $rootScope, $location, group, FormService, Records) ->
    $scope.group = group

    $scope.submit = FormService.submit $scope, $scope.group,
      submitFn: $scope.group.archive
      flashSuccess: 'group_page.messages.archive_group_success'
      successCallback: -> $location.path '/dashboard'
