{ contactUs } = require 'angular/helpers/window.coffee'

angular.module('loomioApp').directive 'authInactiveForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/inactive_form/auth_inactive_form.html'
  controller: ($scope) ->
    $scope.contactUs = ->
      contactUs()
