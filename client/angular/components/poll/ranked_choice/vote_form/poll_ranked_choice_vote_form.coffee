EventBus = require 'shared/services/event_bus'

{ submitOnEnter, registerKeyEvent } = require 'shared/helpers/keyboard'
{ submitStance }                    = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollRankedChoiceVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/ranked_choice/vote_form/poll_ranked_choice_vote_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    initForm = do ->
      $scope.numChoices  = $scope.stance.poll().customFields.minimum_stance_choices
      $scope.pollOptions = _.sortBy $scope.stance.poll().pollOptions(), (option) ->
        choice = _.find($scope.stance.stanceChoices(), _.matchesProperty('pollOptionId', option.id))
        -(choice or {}).score

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'
        $scope.stance.id = null
        selected = _.take $scope.pollOptions, $scope.numChoices
        $scope.stance.stanceChoicesAttributes = _.map selected, (option, index) ->
          poll_option_id: option.id
          score:          $scope.numChoices - index

    $scope.setSelected = (option) ->
      $scope.selectedOption = option

    $scope.selectedOptionIndex = ->
      _.findIndex $scope.pollOptions, $scope.selectedOption

    $scope.isSelected = (option) ->
      $scope.selectedOption == option

    submitOnEnter $scope, element: $element
    registerKeyEvent $scope, 'pressedUpArrow', ->
      swap($scope.selectedOptionIndex(), $scope.selectedOptionIndex() - 1)

    registerKeyEvent $scope, 'pressedDownArrow', ->
      swap($scope.selectedOptionIndex(), $scope.selectedOptionIndex() + 1)

    registerKeyEvent $scope, 'pressedEsc', ->
      $scope.selectedOption = null

    swap = (fromIndex, toIndex) ->
      return unless fromIndex >= 0 and fromIndex < $scope.pollOptions.length and
                    toIndex   >= 0 and toIndex   < $scope.pollOptions.length
      $scope.pollOptions[fromIndex]   = $scope.pollOptions[toIndex]
      $scope.pollOptions[toIndex]     = $scope.selectedOption
  ]
