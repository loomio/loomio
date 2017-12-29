{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'
{ submitStance }  = require 'angular/helpers/form.coffee'

angular.module('loomioApp').directive 'pollProposalVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/proposal/vote_form/poll_proposal_vote_form.html'
  controller: ['$scope', ($scope) ->
    $scope.stance.selectedOption = $scope.stance.pollOption()

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.$emit 'processing'
        return unless $scope.stance.selectedOption
        $scope.stance.stanceChoicesAttributes = [{ poll_option_id: $scope.stance.selectedOption.id }]

    $scope.cancelOption = -> $scope.stance.selected = null

    $scope.reasonPlaceholder = ->
      pollOptionName = ($scope.stance.selectedOption or {name: 'default'}).name
      "poll_proposal_vote_form.#{pollOptionName}_reason_placeholder"

    submitOnEnter($scope)
  ]
