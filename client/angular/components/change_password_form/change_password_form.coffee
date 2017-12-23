Session = require 'shared/services/session.coffee'
Records = require 'shared/services/records.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'ChangePasswordForm', ->
  templateUrl: 'generated/components/change_password_form/change_password_form.html'
  controller: ($scope) ->
    $scope.user = Session.user().clone()

    actionName = if $scope.user.hasPassword then 'password_changed' else 'password_set'

    $scope.submit = submitForm $scope, $scope.user,
      submitFn: Records.users.updateProfile
      flashSuccess: "change_password_form.#{actionName}"
