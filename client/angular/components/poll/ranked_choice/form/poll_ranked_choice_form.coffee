angular.module('loomioApp').directive 'pollRankedChoiceForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/ranked_choice/form/poll_ranked_choice_form.html'
  controller: ['$scope', ($scope) ->
    $scope.poll.setMinimumStanceChoices()
  ]
