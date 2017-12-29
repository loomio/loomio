Session = require 'shared/services/session.coffee'
Records = require 'shared/services/records.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'
{ hardReload } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').factory 'DeactivateUserForm', ->
  templateUrl: 'generated/components/deactivate_user_form/deactivate_user_form.html'
  controller: ['$scope', ($scope) ->
    $scope.user = Session.user().clone()

    $scope.submit = submitForm $scope, $scope.user,
      submitFn: Records.users.deactivate
      successCallback: -> hardReload()
  ]
