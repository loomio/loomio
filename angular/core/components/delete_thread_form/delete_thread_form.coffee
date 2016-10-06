angular.module('loomioApp').factory 'DeleteThreadForm', ->
  templateUrl: 'generated/components/delete_thread_form/delete_thread_form.html'
  controller: ($scope, $location, discussion, FormService, LmoUrlService) ->
    $scope.discussion = discussion
    $scope.group = discussion.group()

    $scope.submit = FormService.submit $scope, $scope.discussion,
      submitFn: $scope.discussion.destroy
      flashSuccess: 'delete_thread_form.messages.success'
      successCallback: ->
        $location.path LmoUrlService.group($scope.group)
