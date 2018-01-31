{ fieldFromTemplate } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonSettings', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/settings/poll_common_settings.html'
  controller: ['$scope', ($scope) ->
    $scope.multipleChoiceOption = ->
      $scope.poll.pollType == 'poll'

    $scope.votersCanAddOptions = ->
      fieldFromTemplate($scope.poll.pollType, 'can_add_options')

    $scope.votersCanBeAnonymous = ->
      fieldFromTemplate($scope.poll.pollType, 'can_vote_anonymously')
  ]
