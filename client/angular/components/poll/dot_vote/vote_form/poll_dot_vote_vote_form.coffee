Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ submitStance }  = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'pollDotVoteVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/dot_vote/vote_form/poll_dot_vote_vote_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.vars = {}

    percentageFor = (choice) ->
      max = $scope.stance.poll().customFields.dots_per_person
      return unless max > 0
      "#{100 * choice.score / max}% 100%"

    backgroundImageFor = (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"

    $scope.styleData = (choice) ->
      option = $scope.optionFor(choice)
      'border-color': option.color
      'background-image': backgroundImageFor(option)
      'background-size': percentageFor(choice)


    $scope.stanceChoiceFor = (option) ->
      _.head(_.filter($scope.stance.stanceChoices(), (choice) ->
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    $scope.adjust = (choice, amount) ->
      choice.score += amount

    $scope.optionFor = (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    $scope.dotsRemaining = ->
      $scope.stance.poll().customFields.dots_per_person - _.sum(_.map($scope.stanceChoices, 'score'))

    $scope.tooManyDots = ->
      $scope.dotsRemaining() < 0

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
        return unless _.sum(_.map($scope.stanceChoices, 'score')) > 0
        $scope.stance.stanceChoicesAttributes = $scope.stanceChoices

    submitOnEnter $scope, element: $element
  ]
