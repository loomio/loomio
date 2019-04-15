<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-inactive-form
  p.lmo-hint-text(translate='auth_form.account_inactive', translate-value-email='{{user.email}}')
  md-button.md-raised.md-primary.auth-inactive-form__submit.auth-inactive-form__reactivate(ng-click='reactivateUser()', translate='auth_form.reactivate')
</template>
<style lang="scss">
</style>

<!-- 
AuthService = require 'shared/services/auth_service'

angular.module('loomioApp').directive 'authInactiveForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/inactive_form/auth_inactive_form.html'
  controller: ['$scope', ($scope) ->
    $scope.reactivateUser =  ->
      AuthService.reactivate($scope.user)
  ] -->
