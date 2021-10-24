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
        Records.users.saveExperience('sidebar', false)
      else
        Records.users.saveExperience('sidebar', true)

    toggleDark: ->
      if @isDark
        Records.users.saveExperience('darkMode', false)
        @$vuetify.theme.dark = false
      else
        Records.users.saveExperience('darkMode', true)
        @$vuetify.theme.dark = true

    signOut: ->
      Session.signOut()

  computed:
    isDark:   -> @$vuetify.theme.dark
    version:  -> AppConfig.version
    release:  -> AppConfig.release
    siteName: -> AppConfig.theme.site_name
    user:     -> Session.user()
    helpLink: -> UserHelpService.helpLink()
    showHelp: -> AppConfig.features.app.help_link
    showContact: -> AppConfig.features.app.show_contact
    showBeta: -> !AppConfig.features.app.thread_page_v3

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
  v-list-item.user-dropdown__list-item-button--profile(to="/profile" dense)
    v-list-item-title(v-t="'user_dropdown.edit_profile'")
    v-list-item-icon
      v-icon mdi-account
  v-list-item.user-dropdown__list-item-button--email-settings(to="/email_preferences" dense)
    v-list-item-title(v-t="'user_dropdown.email_settings'")
    v-list-item-icon
      v-icon mdi-cog-outline
  v-list-item(v-if="!isDark" @click="toggleDark" dense)
      v-list-item-title(v-t="'user_dropdown.enable_dark_mode'")
      v-list-item-icon
        v-icon mdi-weather-night
  v-list-item(v-if="isDark" @click="toggleDark" dense)
      v-list-item-title(v-t="'user_dropdown.disable_dark_mode'")
      v-list-item-icon
        v-icon mdi-white-balance-sunny
  template(v-if="showBeta")
    v-list-item(v-if="!user.experiences['betaFeatures']" @click="toggleBeta" dense)
        v-list-item-title(v-t="'user_dropdown.enable_beta_features'")
        v-list-item-icon
          v-icon mdi-flask-outline
    v-list-item(v-if="user.experiences['betaFeatures']" @click="toggleBeta" dense)
        v-list-item-title(v-t="'user_dropdown.disable_beta_features'")
        v-list-item-icon
          v-icon mdi-flask-empty-off-outline
  v-list-item(v-if="showHelp", :href="helpLink", target="_blank" dense)
    v-list-item-title(v-t="'user_dropdown.help'")
    v-list-item-icon
      v-icon mdi-help-circle-outline
  v-list-item(v-if="showContact" to="/contact" dense)
    v-list-item-title(v-t="{path: 'user_dropdown.contact_support', args: {site_name: siteName}}")
    v-list-item-icon
      v-icon mdi-face-agent
  v-list-item(@click="signOut()" dense)
    v-list-item-title(v-t="'user_dropdown.sign_out'")
    v-list-item-icon
      v-icon mdi-exit-to-app
  v-list-item(href="https://github.com/loomio/loomio/releases" target="_blank" dense :title="release")
    v-list-item-title.text--secondary
      span(v-t="'common.version'")
      space
      span {{version}}

</template>
