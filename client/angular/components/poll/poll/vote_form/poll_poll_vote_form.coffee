EventBus = require 'shared/services/event_bus.coffee'

{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'
{ submitStance }  = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'pollPollVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/poll/vote_form/poll_poll_vote_form.html'
  controller: ['$scope', ($scope) ->
    $scope.vars = {}
    $scope.pollOptionIdsChecked = {}

    initForm = do ->
      if $scope.stance.poll().multipleChoice
        $scope.pollOptionIdsChecked = _.fromPairs _.map $scope.stance.stanceChoices(), (choice) ->
          [choice.pollOptionId, true]
      else
        $scope.vars.pollOptionId = $scope.stance.pollOptionId()

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'
        selectedOptionIds = if $scope.stance.poll().multipleChoice
          _.compact(_.map($scope.pollOptionIdsChecked, (v,k) -> parseInt(k) if v))
        else
          [$scope.vars.pollOptionId]

        if _.any selectedOptionIds
          $scope.stance.stanceChoicesAttributes =
            _.map selectedOptionIds, (id) -> {poll_option_id: id}

    submitOnEnter($scope)
  ]
