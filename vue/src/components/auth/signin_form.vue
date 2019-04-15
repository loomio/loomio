<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-signin-form
  auth_avatar(user='user')
  md-input-container.md-block.auth-signin-form__magic-link
    h2.lmo-h2.align-center(translate='auth_form.welcome_back', translate-value-name='{{user.firstName()}}')
  .auth-signin-form__token.align-center(ng-if='user.hasToken')
    validation_errors(subject='user', field='token')
    md-button.md-primary.md-raised.auth-signin-form__submit(ng-click='submit()', ng-if='!user.errors.token')
      span(translate='auth_form.sign_in_as', translate-value-name='{{user.name}}')
    md-button.md-primary.md-raised.auth-signin-form__submit(ng-click='sendLoginLink()', ng-if='user.errors.token')
      span(translate='auth_form.login_link')
    p
      span(translate='auth_form.set_password_helptext')
      a.lmo-pointer(ng-click='signInAndSetPassword()', translate='auth_form.set_password')
  .auth-signin-form__no-token(ng-if='!user.hasToken')
    p
      span(translate='auth_form.login_link_helptext', ng-if='!user.hasPassword')
      span(translate='auth_form.login_link_helptext_with_password', ng-if='user.hasPassword')
    .auth-signin-form__password(ng-if='user.hasPassword')
      md-input-container.md-block
        label(translate='auth_form.password')
        input#password.lmo-primary-form-input(name='password', type='password', md-autofocus='true', ng-required='ng-required', ng-model='user.password')
        validation_errors(subject='user', field='password')
      .lmo-md-actions
        md-button.auth-signin-form__login-link(ng-click='sendLoginLink()', ng-class="{\'md-primary\': !user.password}")
          span(translate='auth_form.login_link')
        md-button.md-primary.md-raised.auth-signin-form__submit(ng-click='submit()', ng-disabled='!user.password', ng-if='user.hasPassword')
          span(translate='auth_form.sign_in')
    .auth-signin-form__no-password(ng-if='!user.hasPassword')
      .lmo-md-actions
        div
        md-button.md-primary.md-raised.auth-signin-form__submit(ng-click='sendLoginLink()')
          span(translate='auth_form.login_link')
</template>
<style lang="scss">
</style>

<!-- AuthService   = require 'shared/services/auth_service'
EventBus      = require 'shared/services/event_bus'
LmoUrlService = require 'shared/services/lmo_url_service'

{ hardReload }    = require 'shared/helpers/window'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'authSigninForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signin_form/auth_signin_form.html'
  controller: ['$scope', ($scope) ->
    $scope.vars = {}

    $scope.signIn = ->
      EventBus.emit $scope, 'processing'
      $scope.user.name = $scope.vars.name if $scope.vars.name?
      finished = ->
        EventBus.emit $scope, 'doneProcessing';
        $scope.$apply();
      AuthService.signIn($scope.user, hardReload, finished).finally finished

    $scope.signInAndSetPassword = ->
      LmoUrlService.params('set_password', true)
      $scope.signIn()

    $scope.sendLoginLink = ->
      EventBus.emit $scope, 'processing'
      AuthService.sendLoginLink($scope.user).finally -> EventBus.emit $scope, 'doneProcessing'

    $scope.submit = ->
      if $scope.user.hasPassword or $scope.user.hasToken
        $scope.signIn()
      else
        $scope.sendLoginLink()

    submitOnEnter($scope, anyEnter: true)
    EventBus.emit $scope, 'focus'
  ] -->
