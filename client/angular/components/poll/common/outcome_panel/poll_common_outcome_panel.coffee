Records        = require 'shared/services/records'
Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen'

angular.module('loomioApp').directive 'pollCommonOutcomePanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ['$scope', ($scope) ->

    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.poll)
    ,
      name: 'announce_outcome'
      icon: 'mdi-account-plus'
      active:     -> $scope.poll.outcome().announcementsCount == 0
      canPerform: -> AbilityService.canAdministerPoll($scope.poll)
      perform:    -> ModalService.open 'AnnouncementModal', announcement: ->
        Records.announcements.buildFromModel($scope.poll.outcome())
    ,
      name: 'edit_outcome'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canSetPollOutcome($scope.poll)
      perform:    -> ModalService.open 'PollCommonOutcomeModal', outcome: -> $scope.poll.outcome()
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.poll.outcome())
      perform:    -> $scope.poll.outcome().translate(Session.user().locale)
    ]

    listenForTranslations $scope
    listenForReactions $scope, $scope.poll.outcome()
  ]
