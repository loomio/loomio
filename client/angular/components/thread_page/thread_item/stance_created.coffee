AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'stanceCreated', (ModalService, TranslationService) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/stance_created.html'
  replace: true
  controller: ($scope) ->
    $scope.actions = [
      name: 'translate_stance'
      icon: 'mdi-translate'
      canPerform: -> $scope.eventable.reason && AbilityService.canTranslate($scope.eventable)  && !$scope.translation
      perform:    -> TranslationService.inline($scope, $scope.eventable)
    ,
      name: 'edit_stance'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditStance($scope.eventable)
      perform:    -> ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.eventable
    ]

    TranslationService.listenForTranslations($scope)
