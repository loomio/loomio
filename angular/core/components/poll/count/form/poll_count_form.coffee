angular.module('loomioApp').directive 'pollCountForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/count/form/poll_count_form.html'
  controller: ($scope, FormService, AttachmentService, PollService, KeyEventService) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.poll.pollOptionNames = _.pluck PollService.fieldFromTemplate('count', 'poll_options_attributes'), 'name'

    KeyEventService.submitOnEnter($scope)
