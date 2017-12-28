{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'
{ submitStance }  = require 'angular/helpers/form.coffee'
{ fromPairs }     = require 'angular/helpers/util.coffee'

angular.module('loomioApp').directive 'pollMeetingVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/vote_form/poll_meeting_vote_form.html'
  controller: ($scope) ->
    $scope.vars = {}

    initForm = do ->
      $scope.pollOptionIdsChecked = fromPairs _.map $scope.stance.stanceChoices(), (choice) ->
        [choice.pollOptionId, true]

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.$emit 'processing'
        attrs = _.map _.compact(_.map($scope.pollOptionIdsChecked, (v,k) -> parseInt(k) if v)), (id) -> {poll_option_id: id}
        $scope.stance.stanceChoicesAttributes = attrs if _.any(attrs)

    $scope.$on 'timeZoneSelected', (e, zone) ->
      $scope.zone = zone

    submitOnEnter($scope)
