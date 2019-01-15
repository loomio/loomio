EventBus = require 'shared/services/event_bus'

{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollCommonCloseFormActions', ->
  scope: {poll: '='}
  template: require('./poll_common_close_form_actions.haml')
  controller: ['$scope', ($scope) ->

    $scope.submit = submitForm $scope, $scope.poll,
      submitFn: $scope.poll.close
      flashSuccess: "poll_common_close_form.#{$scope.poll.pollType}_closed"
      successCallback: ->
        EventBus.emit $scope, 'nextStep', $scope.poll
  ]
