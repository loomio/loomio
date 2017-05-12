angular.module('loomioApp').directive 'pollCommonFormOptions', () ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_options/poll_common_form_options.html'
  controller: ($scope, KeyEventService) ->
    $scope.existingOptions = _.clone $scope.poll.pollOptionNames

    $scope.addOption = ->
      return unless $scope.newOptionName and !_.contains($scope.poll.pollOptionNames, $scope.newOptionName)
      $scope.poll.pollOptionNames.push $scope.newOptionName
      $scope.poll.makeAnnouncement = true unless $scope.poll.isNew()
      $scope.newOptionName = ''

    $scope.$on 'addPollOption', () ->
      $scope.addOption()

    $scope.removeOption = (name) ->
      _.pull($scope.poll.pollOptionNames, name) unless $scope.isExisting(name)

    $scope.isExisting = (name) ->
      _.contains $scope.existingOptions, name

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addOption, (active) ->
      active.classList.contains('poll-poll-form__add-option-input')
