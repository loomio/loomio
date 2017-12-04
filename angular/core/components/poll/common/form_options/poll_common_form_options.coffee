angular.module('loomioApp').directive 'pollCommonFormOptions', (PollService, AbilityService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_options/poll_common_form_options.html'
  controller: ($scope, KeyEventService) ->
    $scope.existingOptions = _.clone $scope.poll.pollOptionNames

    $scope.addOption = ->
      return unless $scope.poll.newOptionName and !_.contains($scope.poll.pollOptionNames, $scope.poll.newOptionName)
      $scope.poll.pollOptionNames.push $scope.poll.newOptionName
      $scope.poll.makeAnnouncement = true unless $scope.poll.isNew()
      $scope.$emit 'pollOptionsChanged', $scope.poll.newOptionName
      $scope.poll.newOptionName = ''

    $scope.datesAsOptions = PollService.fieldFromTemplate($scope.poll.pollType, 'dates_as_options')

    $scope.$on 'addPollOption', ->
      $scope.addOption()

    $scope.removeOption = (name) ->
      _.pull($scope.poll.pollOptionNames, name)
      $scope.$emit 'pollOptionsChanged'

    $scope.isExisting = (name) ->
      _.contains $scope.existingOptions, name

    $scope.canRemoveOption = (name) ->
      !$scope.isExisting(name) || AbilityService.canRemovePollOptions($scope.poll)

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addOption, (active) ->
      active.classList.contains('poll-poll-form__add-option-input')
