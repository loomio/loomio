AuthService = require 'shared/services/auth_service'

angular.module('loomioApp').directive 'authInactiveForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/inactive_form/auth_inactive_form.html'
  controller: ['$scope', ($scope) ->
    $scope.reactivateUser =  ->
      AuthService.reactivate($scope.user)
  ]
