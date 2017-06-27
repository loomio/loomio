angular.module('loomioApp').directive 'pollCommonAddOptionForm', (PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/add_option/form/poll_common_add_option_form.html'
  replace: true
  controller: ($scope, $rootScope) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      submitFn: $scope.poll.addOptions
      prepareFn: ->
        $scope.$broadcast 'addPollOption'
        $scope.$emit 'processing'
      successCallback: ->
        $scope.$emit '$close'
        $rootScope.$broadcast 'pollOptionsAdded', $scope.poll
      flashSuccess: "poll_common_add_option.form.options_added"
