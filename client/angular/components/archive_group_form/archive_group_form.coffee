Records = require 'shared/services/records.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'ArchiveGroupForm', ->
  templateUrl: 'generated/components/archive_group_form/archive_group_form.html'
  controller: ($scope, $location, group) ->
    $scope.group = group

    $scope.submit = submitForm $scope, $scope.group,
      submitFn: $scope.group.archive
      flashSuccess: 'group_page.messages.archive_group_success'
      successCallback: -> $location.path '/dashboard'
