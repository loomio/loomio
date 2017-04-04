angular.module('loomioApp').directive 'pollCommonFormOptions', () ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_options/poll_common_form_options.html'
  controller: ($scope, KeyEventService) ->
    $scope.addOption = ->
      return unless $scope.newOptionName
      $scope.poll.pollOptionNames.push $scope.newOptionName
      $scope.newOptionName = ''

    $scope.$on 'addPollOption', () ->
      $scope.addOption()

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addOption, (active) ->
      active.classList.contains('poll-poll-form__add-option-input')
