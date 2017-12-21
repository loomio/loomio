angular.module('loomioApp').directive 'pollCommonDetailsPanel', (Records, AbilityService, DocumentModal, ModalService, PollCommonEditModal, TranslationService, ReactionService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/details_panel/poll_common_details_panel.html'
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.poll)
    ,
      name: 'translate_poll'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.poll) && !$scope.translation
      perform:    -> TranslationService.inline($scope, $scope.poll)
    ,
      name: 'add_resource'
      icon: 'mdi-attachment'
      canPerform: -> AbilityService.canAdministerPoll($scope.poll)
      perform:    -> ModalService.open DocumentModal, doc: ->
        Records.documents.build
          modelId:   $scope.poll.id
          modelType: 'Poll'
    ,
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditPoll($scope.poll)
      perform:    -> ModalService.open PollCommonEditModal, poll: -> $scope.poll
    ]

    TranslationService.listenForTranslations($scope)
    ReactionService.listenForReactions($scope, $scope.poll)
