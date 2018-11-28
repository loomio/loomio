Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ submitStance }  = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'pollScoreVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/score/vote_form/poll_score_vote_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.vars = {}

    $scope.stanceChoiceFor = (option) ->
      _.head(_.filter($scope.stance.stanceChoices(), (choice) ->
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    $scope.optionFor = (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    $scope.setStanceChoices = ->
      $scope.stanceChoices = _.map $scope.stance.poll().pollOptions(), (option) ->
        poll_option_id: option.id
        score: $scope.stanceChoiceFor(option).score
    $scope.setStanceChoices()
    EventBus.listen $scope, 'pollOptionsAdded', $scope.setStanceChoices

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'
        $scope.stance.id = null
        $scope.stance.stanceChoicesAttributes = $scope.stanceChoices

    submitOnEnter $scope, element: $element
  ]
