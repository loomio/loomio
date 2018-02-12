Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
AppConfig      = require 'shared/services/app_config.coffee'

{ submitForm } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'contactForm', ->
  templateUrl: 'generated/components/contact/form/contact_form.html'
  controller: ['$scope', ($scope) ->
    $scope.contactEmail = AppConfig.contactEmail

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()

    $scope.message = Records.contactMessages.build()
    if $scope.isLoggedIn()
      $scope.message.name = Session.user().name
      $scope.message.email = Session.user().email

    $scope.submit = submitForm $scope, $scope.message,
      flashSuccess: "contact_message_form.new_contact_message"
  ]
