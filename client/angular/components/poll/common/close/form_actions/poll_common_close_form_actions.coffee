EventBus = require 'shared/services/event_bus'

{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollCommonCloseFormActions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/close/form_actions/poll_common_close_form_actions.html'
  controller: ['$scope', ($scope) ->

    $scope.submit = submitForm $scope, $scope.poll,
      submitFn: $scope.poll.close
      flashSuccess: "poll_common_close_form.#{$scope.poll.pollType}_closed"
      successCallback: ->
        EventBus.emit $scope, 'nextStep', $scope.poll
  ]
