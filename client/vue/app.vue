<script lang="coffee">

FlashService = require 'shared/services/flash_service'
AppConfig    = require 'shared/services/app_config'
{ signIn }  = require 'shared/helpers/user'

module.exports =
  methods:
    loggedIn: ->
      FlashService.success AppConfig.userPayload.flash.notice
      # $scope.pageError = null
      # $scope.refreshing = true
      # $injector.get('$timeout') ->
      #   $scope.refreshing = false
        # FlashService.success AppConfig.userPayload.flash.notice
      #   delete AppConfig.userPayload.flash.notice
      # if LmoUrlService.params().set_password
      #   delete LmoUrlService.params().set_password
      #   ModalService.open 'ChangePasswordForm'
  created: ->
    signIn(AppConfig.userPayload, AppConfig.userPayload.current_user_id, @loggedIn)

</script>

<template>
  <v-app>
    <sidebar></sidebar>
    <v-content>
      <router-view></router-view>
    </v-content>
  </v-app>
</template>
