Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ applyLoadingFunction } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').directive 'currentPollsCard', ->
  scope: {model: '='}
  templateUrl: 'generated/components/current_polls_card/current_polls_card.html'
  controller: ['$scope', ($scope) ->
    $scope.fetchRecords = ->
      Records.polls.fetchFor($scope.model, status: 'active')
    applyLoadingFunction $scope, 'fetchRecords'
    $scope.fetchRecords()

    $scope.polls = ->
      _.take $scope.model.activePolls(), ($scope.limit or 50)

    $scope.startPoll = ->
      ModalService.open 'PollCommonStartModal', poll: ->
        if $scope.model.isA('discussion')
          Records.polls.build(discussionId: $scope.model.id, groupId: $scope.model.groupId)
        else if $scope.model.isA('group')
          Records.polls.build(groupId: $scope.model.id)

    $scope.canStartPoll = ->
      AbilityService.canStartPoll($scope.model.group())
  ]
