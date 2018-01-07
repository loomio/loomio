EventBus = require 'shared/services/event_bus.coffee'

{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'
{ submitStance }  = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'pollMeetingVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/vote_form/poll_meeting_vote_form.html'
  controller: ['$scope', ($scope) ->
    $scope.vars = {}

    initForm = do ->
      $scope.pollOptionIdsChecked = _.fromPairs _.map $scope.stance.stanceChoices(), (choice) ->
        [choice.pollOptionId, true]

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'
        attrs = _.map _.compact(_.map($scope.pollOptionIdsChecked, (v,k) -> parseInt(k) if v)), (id) -> {poll_option_id: id}
        $scope.stance.stanceChoicesAttributes = attrs if _.any(attrs)

    EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
      $scope.zone = zone

    submitOnEnter($scope)
  ]
