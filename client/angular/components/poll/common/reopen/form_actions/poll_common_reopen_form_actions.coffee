moment = require 'moment'

EventBus = require 'shared/services/event_bus'

{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollCommonReopenFormActions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/reopen/form_actions/poll_common_reopen_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.poll.closingAt = moment().add(1, 'day')

    $scope.submit = submitForm $scope, $scope.poll,
      submitFn: $scope.poll.reopen
      flashSuccess: "poll_common_reopen_form.#{$scope.poll.pollType}_reopened"
      successCallback: ->
        EventBus.emit $scope, '$close'
  ]
