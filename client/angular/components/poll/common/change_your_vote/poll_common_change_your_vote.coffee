ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'pollCommonChangeYourVote', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/change_your_vote/poll_common_change_your_vote.html'
  controller: ['$scope', ($scope) ->
    $scope.openStanceForm = ->
      ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.stance
  ]
