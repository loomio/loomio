<script lang="coffee">
import AppConfig       from '@/shared/services/app_config'
import Session         from '@/shared/services/session'
import Records         from '@/shared/services/records'
import UserHelpService from '@/shared/services/user_help_service'
import Flash from '@/shared/services/flash'

export default
  methods:
    togglePinned: ->
      if @user.experiences['sidebar']
        Records.users.removeExperience('sidebar')
      else
        Records.users.saveExperience('sidebar')

    toggleBeta: ->
      if @user.experiences['betaFeatures']
        Records.users.removeExperience('betaFeatures')
      else
        Records.users.saveExperience('betaFeatures')
        Flash.success("user_dropdown.beta_collab")

    toggleDark: ->
      if @user.experiences['darkMode']
        Records.users.removeExperience('darkMode')
        @$vuetify.theme.dark = false
      else
        Records.users.saveExperience('darkMode')
        @$vuetify.theme.dark = true

    signOut: ->
      Session.signOut()

  computed:
    siteName: -> AppConfig.theme.site_name
    user:     -> Session.user()
    helpLink: -> UserHelpService.helpLink()
    showHelp: -> AppConfig.features.app.help_link

</script>

<template lang="pug">
div.user-dropdown
  v-list-item(v-if="!user.experiences['sidebar']" @click="togglePinned" dense)
      v-list-item-title(v-t="'user_dropdown.pin_sidebar'")
      v-list-item-icon
        v-icon mdi-pin
  v-list-item(v-if="user.experiences['sidebar']" @click="togglePinned" dense)
      v-list-item-title(v-t="'user_dropdown.unpin_sidebar'")
      v-list-item-icon
        v-icon mdi-pin-off
  v-list-item(v-if="!user.experiences['betaFeatures']" @click="toggleBeta" dense)
      v-list-item-title(v-t="'user_dropdown.enable_beta_features'")
      v-list-item-icon
        v-icon mdi-flask-outline
  v-list-item(v-if="user.experiences['betaFeatures']" @click="toggleBeta" dense)
      v-list-item-title(v-t="'user_dropdown.disable_beta_features'")
      v-list-item-icon
        v-icon mdi-flask-empty-off-outline
  v-list-item(v-if="user.experiences['betaFeatures'] && !user.experiences['darkMode']" @click="toggleDark" dense)
      v-list-item-title(v-t="'user_dropdown.enable_dark_mode'")
      v-list-item-icon
        v-icon mdi-weather-night
  v-list-item(v-if="user.experiences['darkMode']" @click="toggleDark" dense)
      v-list-item-title(v-t="'user_dropdown.disable_dark_mode'")
      v-list-item-icon
        v-icon mdi-white-balance-sunny
  v-list-item.user-dropdown__list-item-button--profile(to="/profile" dense)
    v-list-item-title(v-t="'user_dropdown.edit_profile'")
    v-list-item-icon
      v-icon mdi-account
  v-list-item.user-dropdown__list-item-button--email-settings(to="/email_preferences" dense)
    v-list-item-title(v-t="'user_dropdown.email_settings'")
    v-list-item-icon
      v-icon mdi-cog-outline
  v-list-item(v-if="showHelp", :href="helpLink", target="_blank" dense)
    v-list-item-title(v-t="'user_dropdown.help'")
    v-list-item-icon
      v-icon mdi-help-circle-outline
  v-list-item(to="/contact" dense)
    v-list-item-title(v-t="{path: 'user_dropdown.contact_support', args: {site_name: siteName}}")
    v-list-item-icon
      v-icon mdi-email-outline
  v-list-item(@click="signOut()" dense)
    v-list-item-title(v-t="'user_dropdown.sign_out'")
    v-list-item-icon
      v-icon mdi-exit-to-app
</template>
