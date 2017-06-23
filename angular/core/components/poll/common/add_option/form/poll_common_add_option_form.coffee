angular.module('loomioApp').directive 'pollCommonAddOptionForm', (PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/add_option/form/poll_common_add_option_form.html'
  replace: true
  controller: ($scope, $rootScope) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      submitFn: $scope.poll.addOptions
      successCallback: ->
        $scope.$emit '$close'
        $rootScope.$broadcast 'pollSaved', $scope.poll
      flashSuccess: "poll_common_add_option.form.options_added"
