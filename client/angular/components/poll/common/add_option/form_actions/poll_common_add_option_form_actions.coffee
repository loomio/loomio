EventBus = require 'shared/services/event_bus'

{ submitPoll } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollCommonAddOptionFormActions', ->
  scope: {poll: '='}
  template: require('./poll_common_add_option_form_actions.haml')
  replace: true
  controller: ['$scope', '$rootScope', ($scope, $rootScope) ->
    $scope.submit = submitPoll $scope, $scope.poll,
      submitFn: $scope.poll.addOptions
      prepareFn: ->
        $scope.poll.addOption()
        EventBus.emit $scope, 'processing'
      successCallback: ->
        EventBus.broadcast $rootScope, 'pollOptionsAdded', $scope.poll
      flashSuccess: "poll_common_add_option.form.options_added"
  ]
