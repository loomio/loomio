angular.module('loomioApp').directive 'pollScoreForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/score/form/poll_score_form.html'
  controller: ['$scope', ($scope) ->
    $scope.poll.customFields.max_score = $scope.poll.customFields.max_score or 9
  ]
