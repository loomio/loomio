angular.module('loomioApp').directive 'pollCommonDetailsPanel', (AbilityService, ModalService, PollCommonFormModal, TranslationService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/details_panel/poll_common_details_panel.html'
  controller: ($scope) ->
    $scope.actions = [
      name: 'translate_poll'
      icon: 'translate'
      canPerform: -> AbilityService.canTranslate($scope.poll) && !$scope.translation
      perform:    -> TranslationService.inline($scope, $scope.poll)
    ,
      name: 'edit_poll'
      icon: 'edit'
      canPerform: -> AbilityService.canEditPoll($scope.poll)
      perform:    -> ModalService.open PollCommonFormModal, poll: -> $scope.poll
    ]

    TranslationService.listenForTranslations($scope)
