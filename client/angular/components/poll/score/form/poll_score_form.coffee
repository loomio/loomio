angular.module('loomioApp').directive 'pollScoreForm', ->
  scope: {poll: '='}
  template: require('./poll_score_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.poll.customFields.max_score = $scope.poll.customFields.max_score or 9
  ]
