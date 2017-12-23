LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'DeleteThreadForm', ($location) ->
  templateUrl: 'generated/components/delete_thread_form/delete_thread_form.html'
  controller: ($scope, discussion) ->
    $scope.discussion = discussion
    $scope.group = discussion.group()

    $scope.submit = submitForm $scope, $scope.discussion,
      submitFn: $scope.discussion.destroy
      flashSuccess: 'delete_thread_form.messages.success'
      successCallback: ->
        $location.path LmoUrlService.group($scope.group)
