angular.module('loomioApp').directive 'pollCommonFormFields', ($translate) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_fields/poll_common_form_fields.html'
  controller: ($scope) ->
    $scope.titlePlaceholder = ->
      $translate.instant("poll_#{$scope.poll.pollType}_form.title_placeholder")

    $scope.detailsPlaceholder = ->
      $translate.instant("poll_#{$scope.poll.pollType}_form.details_placeholder")
