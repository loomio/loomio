ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'pollCommonChangeYourVote', ->
  scope: {stance: '='}
  template: require('./poll_common_change_your_vote.haml')
  controller: ['$scope', ($scope) ->
    $scope.openStanceForm = ->
      ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.stance
  ]
