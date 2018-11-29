Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
EventBus       = require 'shared/services/event_bus'

{ registerKeyEvent }  = require 'shared/helpers/keyboard'
{ fieldFromTemplate } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonFormOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_options/poll_common_form_options.html'
  controller: ['$scope', ($scope) ->
    $scope.currentZone = ->
      Session.user().timeZone

    $scope.existingOptions = _.clone $scope.poll.pollOptionNames

    $scope.datesAsOptions = fieldFromTemplate($scope.poll.pollType, 'dates_as_options')

    $scope.removeOption = (name) ->
      _.pull($scope.poll.pollOptionNames, name)
      $scope.poll.setMinimumStanceChoices()

    $scope.canRemoveOption = (name) ->
      _.includes($scope.existingOptions, name) || AbilityService.canRemovePollOptions($scope.poll)

    registerKeyEvent $scope, 'pressedEnter', $scope.poll.addOption, (active) ->
      active.classList.contains('poll-poll-form__add-option-input')
  ]
