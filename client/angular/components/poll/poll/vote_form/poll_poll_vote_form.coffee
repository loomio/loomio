EventBus = require 'shared/services/event_bus'

{ submitOnEnter } = require 'shared/helpers/keyboard'
{ submitStance }  = require 'shared/helpers/form'
{ buttonStyle }   = require 'shared/helpers/style'

angular.module('loomioApp').directive 'pollPollVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/poll/vote_form/poll_poll_vote_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.selectedOptionIds = _.compact $scope.stance.pollOptionIds()

    $scope.select = (option) ->
      if $scope.stance.poll().multipleChoice
        if $scope.isSelected(option)
          _.pull($scope.selectedOptionIds, option.id)
        else
          $scope.selectedOptionIds.push option.id
      else
        $scope.selectedOptionIds = [option.id]
        setTimeout -> EventBus.broadcast $scope, 'focusTextarea'

    $scope.mdColors = (option) ->
      buttonStyle $scope.isSelected(option)

    $scope.isSelected = (option) ->
      _.includes $scope.selectedOptionIds, option.id

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'
        $scope.stance.id = null
        $scope.stance.stanceChoicesAttributes = _.map $scope.selectedOptionIds, (id) ->
          poll_option_id: id

    submitOnEnter $scope, element: $element
  ]
