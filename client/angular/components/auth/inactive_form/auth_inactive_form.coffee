AuthService = require 'shared/services/auth_service'

angular.module('loomioApp').directive 'authInactiveForm', ->
  scope: {user: '='}
  template: require('./auth_inactive_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.reactivateUser =  ->
      AuthService.reactivate($scope.user)
  ]
