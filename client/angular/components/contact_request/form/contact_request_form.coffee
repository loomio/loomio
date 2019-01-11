Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'contactRequestForm', ->
  scope: {user: '='}
  template: require('./contact_request_form.haml')
  controller: ['$scope', ($scope) ->

    $scope.contactRequest = Records.contactRequests.build(recipientId: $scope.user.id)

    $scope.submit = submitForm $scope, $scope.contactRequest,
      flashSuccess: "contact_request_form.email_sent"
      flashOptions: {name: $scope.user.name}
      successCallback: -> EventBus.emit $scope, '$close'

    submitOnEnter $scope
  ]
