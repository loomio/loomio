EventBus = require 'shared/services/event_bus.coffee'

{ submitPoll } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'pollCommonAddOptionForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/add_option/form/poll_common_add_option_form.html'
  replace: true
  controller: ['$scope', '$rootScope', ($scope, $rootScope) ->
    $scope.submit = submitPoll $scope, $scope.poll,
      submitFn: $scope.poll.addOptions
      prepareFn: ->
        EventBus.broadcast $scope, 'addPollOption'
        EventBus.emit $scope, 'processing'
      successCallback: ->
        EventBus.emit $scope, '$close'
        EventBus.broadcast $rootScope, 'pollOptionsAdded', $scope.poll
      flashSuccess: "poll_common_add_option.form.options_added"
  ]
