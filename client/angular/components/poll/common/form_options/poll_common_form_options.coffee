Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
TimeService    = require 'shared/services/time_service.coffee'

{ registerKeyEvent }  = require 'angular/helpers/keyboard.coffee'
{ fieldFromTemplate } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonFormOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_options/poll_common_form_options.html'
  controller: ['$scope', ($scope) ->
    $scope.currentZone = ->
      Session.user().timeZone

    $scope.existingOptions = _.clone $scope.poll.pollOptionNames

    $scope.addOption = ->
      return unless $scope.poll.newOptionName and !_.contains($scope.poll.pollOptionNames, $scope.poll.newOptionName)
      $scope.poll.pollOptionNames.push $scope.poll.newOptionName
      $scope.poll.makeAnnouncement = true unless $scope.poll.isNew()
      $scope.$emit 'pollOptionsChanged', $scope.poll.newOptionName
      $scope.poll.newOptionName = ''

    $scope.datesAsOptions = fieldFromTemplate($scope.poll.pollType, 'dates_as_options')

    $scope.$on 'addPollOption', ->
      $scope.addOption()

    $scope.removeOption = (name) ->
      _.pull($scope.poll.pollOptionNames, name)
      $scope.$emit 'pollOptionsChanged'

    $scope.canRemoveOption = (name) ->
      _.contains($scope.existingOptions, name) || AbilityService.canRemovePollOptions($scope.poll)

    registerKeyEvent $scope, 'pressedEnter', $scope.addOption, (active) ->
      active.classList.contains('poll-poll-form__add-option-input')
  ]
