AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ listenForTranslations, performTranslation } = require 'angular/helpers/translation.coffee'
{ listenForReactions } = require 'angular/helpers/emoji.coffee'

angular.module('loomioApp').directive 'pollCommonOutcomePanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ($scope) ->

    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.poll)
    ,
      name: 'edit_outcome'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canSetPollOutcome($scope.poll)
      perform:    -> ModalService.open 'PollCommonOutcomeModal', outcome: -> $scope.poll.outcome()
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.poll.outcome())
      perform:    -> performTranslation($scope, $scope.poll.outcome())
    ]

    listenForTranslations $scope
    listenForReactions $scope, $scope.poll.outcome()
