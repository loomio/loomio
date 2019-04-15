<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-complete
  auth_avatar(user='user')
  h2.lmo-h2(translate='auth_form.check_your_email')
  p(ng-if='user.sentLoginLink')
    span(translate='auth_form.login_link_sent', translate-value-email='{{user.email}}')
    br
    span(translate='auth_form.instructions', ng-if='attempts < 3')
  .lmo-validation-error(translate='auth_form.too_many_attempts', ng-if='attempts >= 3')
  p
  p.lmo-hint-text(ng-if='user.sentPasswordLink', translate='auth_form.password_link_sent', translate-value-email='{{user.email}}')
  .auth-complete__code-input(ng-if='user.sentLoginLink && attempts < 3')
    md-input-container.auth-complete__code.md-no-errors
      input.lmo-primary-form-input(type='integer', maxlength='6', ng-model='session.code')
    validation_errors(subject='session', field='password')
    br
    span(translate='auth_form.check_spam_folder')
    .lmo-md-action
      md-button.md-raised.md-primary(ng-click='submit()', ng-disabled='!session.code', translate='auth_form.sign_in')
</template>
<style lang="scss">
</style>

<!-- Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'
I18n     = require 'shared/services/i18n'

{ hardReload }    = require 'shared/helpers/window'
{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'authComplete', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/complete/auth_complete.html'
  controller: ['$scope', ($scope) ->
    $scope.session = Records.sessions.build(email: $scope.user.email)
    $scope.attempts = 0

    $scope.submit = submitForm $scope, $scope.session,
      successCallback: -> hardReload()
      failureCallback: ->
        $scope.attempts += 1
        EventBus.emit $scope, 'doneProcessing'
      skipDoneProcessing: true

    submitOnEnter($scope, anyEnter: true)
  ] -->
