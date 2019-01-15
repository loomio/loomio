Session = require 'shared/services/session'
Records = require 'shared/services/records'

{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').factory 'ChangePasswordForm', ->
  template: require('./change_password_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.user = Session.user().clone()

    actionName = if $scope.user.hasPassword then 'password_changed' else 'password_set'

    $scope.submit = submitForm $scope, $scope.user,
      submitFn: Records.users.updateProfile
      flashSuccess: "change_password_form.#{actionName}"
  ]
