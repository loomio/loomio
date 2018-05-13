ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'pollMeetingChangeYourVote', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/change_your_vote/poll_meeting_change_your_vote.html'
  controller: ['$scope', ($scope) ->
    $scope.openStanceForm = ->
      ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.stance
  ]
