EventBus = require 'shared/services/event_bus'

{ submitOnEnter } = require 'shared/helpers/keyboard'
{ submitStance }  = require 'shared/helpers/form'
{ buttonStyle }   = require 'shared/helpers/style'

angular.module('loomioApp').directive 'pollMeetingVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/vote_form/poll_meeting_vote_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.vars = {}

    initForm = do ->
      # initailization of the form pulls the current set values from the model
      choices = $scope.stance.stanceChoices()

      # create the map referenced from the view which requires has an integer for each
      $scope.stanceValuesMap = _.fromPairs _.map $scope.stance.poll().pollOptions(), (option) ->
        stanceChoice = $scope.stance.stanceChoices().find((sc) -> sc.pollOptionId == option.id) or {}
        [option.id, stanceChoice.score or 0]

      $scope.canRespondMaybe = $scope.stance.poll().customFields.can_respond_maybe
      $scope.stanceValues = if $scope.canRespondMaybe then [2,1,0] else [2, 0]

    $scope.selectedColor = (option, score) ->
      buttonStyle(score == $scope.stanceValuesMap[option.id])

    $scope.click = (optionId, score)->
      $scope.stanceValuesMap[optionId] = score

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'
        $scope.stance.id = null
        attrs = _.compact _.map(_.toPairs($scope.stanceValuesMap), ([id, score]) ->
            {poll_option_id: id, score:score} if score > 0
        )

        $scope.stance.stanceChoicesAttributes = attrs if _.some(attrs)

    EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
      $scope.zone = zone

    submitOnEnter $scope, element: $element
  ]
