angular.module('loomioApp').directive 'pollCommonFormActions', () ->
  scope: {submit: '=', poll: '='}
  templateUrl: 'generated/components/poll/common/form_actions/poll_common_form_actions.html'
  controller: ($scope) ->
    $scope.back = ->
      $scope.poll.pollType = null
      $scope.$emit 'saveBack'
