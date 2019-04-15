<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-avatar
  user_avatar.auth-avatar__avatar(user='avatarUser', size='large', no-link='true')
</template>
<style lang="scss">
</style>

<!-- Records = require 'shared/services/records'

angular.module('loomioApp').directive 'authAvatar', ->
  scope: {user: '=?'}
  templateUrl: 'generated/components/auth/avatar/auth_avatar.html'
  controller: ['$scope', ($scope) ->
    $scope.user = $scope.user or {avatarKind: 'initials'}
    if _.includes(['initials', 'mdi-email-outline'], $scope.user.avatarKind)
      $scope.avatarUser = Records.users.build
        avatarKind:  'uploaded'
        avatarUrl:
          small:  '/img/mascot.png'
          medium: '/img/mascot.png'
          large:  '/img/mascot.png'
    else
      $scope.avatarUser = $scope.user
  ] -->
