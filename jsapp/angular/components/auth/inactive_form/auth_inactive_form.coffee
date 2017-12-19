angular.module('loomioApp').directive 'authInactiveForm', (IntercomService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/inactive_form/auth_inactive_form.html'
  controller: ($scope) ->
    $scope.contactUs = ->
      IntercomService.contactUs()
