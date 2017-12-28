{ fieldFromTemplate } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonVoterAddOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/voter_add_options/poll_common_voter_add_options.html'
  controller: ($scope) ->
    $scope.validPollType = ->
      fieldFromTemplate($scope.poll.pollType, 'can_add_options')
