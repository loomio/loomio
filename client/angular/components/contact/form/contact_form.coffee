Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'contactForm', (FormService) ->
  templateUrl: 'generated/components/contact/form/contact_form.html'
  controller: ($scope) ->

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()

    $scope.message = Records.contactMessages.build()
    if $scope.isLoggedIn()
      $scope.message.name = Session.user().name
      $scope.message.email = Session.user().email

    $scope.submit = FormService.submit $scope, $scope.message,
      flashSuccess: "contact_message_form.new_contact_message"
