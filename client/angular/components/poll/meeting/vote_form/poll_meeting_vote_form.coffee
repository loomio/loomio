EventBus = require 'shared/services/event_bus.coffee'

{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'
{ submitStance }  = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'pollMeetingVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/vote_form/poll_meeting_vote_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.vars = {}

    initForm = do ->
      # initailization of the form pulls the current set values from the model
      choices = $scope.stance.stanceChoices()

      # create the map referenced from the view which requires has an integer for each
      $scope.stanceValuesMap = _.fromPairs(_.map( choices, (choice)-> ([choice.pollOptionId, choice.score||0])))

    $scope.click = (optionId)->

      canRespondMaybe = $scope.stance.poll().customFields.can_respond_maybe
      $scope.stanceValuesMap[optionId] = {
        0: 2,
        1: 0,
        2: if canRespondMaybe then 1 else 0
      }[$scope.stanceValuesMap[optionId] || 0]

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'

        attrs = _.map(_.pairs($scope.stanceValuesMap), ([id, score]) ->
            poll_option_id: id
            score:score
        )

        $scope.stance.stanceChoicesAttributes = attrs if _.any(attrs)

    EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
      $scope.zone = zone

    submitOnEnter $scope, element: $element
  ]
