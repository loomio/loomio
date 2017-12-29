{ contactUs } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'authInactiveForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/inactive_form/auth_inactive_form.html'
  controller: ['$scope', ($scope) ->
    $scope.contactUs = ->
      contactUs()
  ]
