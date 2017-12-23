AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'pollCreated', (TranslationService, ReactionService, ModalService) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/outcome_created.html'
  replace: true
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.eventable.poll())
    ,
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditPoll($scope.eventable)
      perform:    -> ModalService.open 'PollCommonEditModal', poll: -> $scope.eventable
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.eventable)
      perform:    -> TranslationService.inline($scope, $scope.eventable)
    ]

    ReactionService.listenForReactions $scope, $scope.eventable
    TranslationService.listenForTranslations $scope,
