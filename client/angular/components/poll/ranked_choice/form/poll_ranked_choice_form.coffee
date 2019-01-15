angular.module('loomioApp').directive 'pollRankedChoiceForm', ->
  scope: {poll: '='}
  template: require('./poll_ranked_choice_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.poll.setMinimumStanceChoices()
  ]
