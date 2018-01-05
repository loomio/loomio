EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').directive 'pollRankedChoiceForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/ranked_choice/form/poll_ranked_choice_form.html'
  controller: ['$scope', ($scope) ->
    setMinimumStanceChoices = ->
      return unless $scope.poll.isNew()
      $scope.poll.customFields.minimum_stance_choices =
        _.max [$scope.poll.pollOptionNames.length, 1]
    setMinimumStanceChoices()
    EventBus.listen $scope, 'pollOptionsChanged', setMinimumStanceChoices
  ]
