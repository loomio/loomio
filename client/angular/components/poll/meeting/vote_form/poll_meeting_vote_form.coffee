EventBus = require 'shared/services/event_bus.coffee'

{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'
{ submitStance }  = require 'shared/helpers/form.coffee'
{ buttonStyle }   = require 'shared/helpers/style.coffee'

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

      $scope.canRespondMaybe = $scope.stance.poll().customFields.can_respond_maybe
      $scope.stanceValues = if $scope.canRespondMaybe then [2,1,0] else [2, 0]

    $scope.selectedColor = (option, score) ->
      buttonStyle(score == $scope.stanceValuesMap[option.id])

    $scope.click = (optionId, score)->
      $scope.stanceValuesMap[optionId] = score

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
