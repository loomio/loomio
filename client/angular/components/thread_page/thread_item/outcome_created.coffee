AbilityService = require 'shared/services/ability_service.coffee'

{ listenForTranslations, performTranslation } = require 'angular/helpers/translation.coffee'
{ listenForReactions } = require 'angular/helpers/emoji.coffee'

angular.module('loomioApp').directive 'outcomeCreated', (ModalService) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/outcome_created.html'
  replace: true
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.eventable.poll())
    ,
      name: 'edit_outcome'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canSetPollOutcome($scope.eventable.poll())
      perform:    -> ModalService.open 'PollCommonOutcomeModal', outcome: -> $scope.eventable
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.eventable)
      perform:    -> performTranslation($scope, $scope.eventable)
    ]

    listenForReactions $scope, $scope.eventable
    listenForTranslations $scope,
