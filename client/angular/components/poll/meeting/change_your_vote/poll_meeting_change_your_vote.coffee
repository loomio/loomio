ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'pollMeetingChangeYourVote', ->
  scope: {stance: '='}
  template: require('./poll_meeting_change_your_vote.haml')
  controller: ['$scope', ($scope) ->
    $scope.openStanceForm = ->
      ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.stance
  ]
