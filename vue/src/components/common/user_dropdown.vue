<script lang="coffee">
import AppConfig       from '@/shared/services/app_config'
import Session         from '@/shared/services/session'
import UserHelpService from '@/shared/services/user_help_service'

export default
  methods:
    signOut: ->
      Session.signOut()

  computed:
    siteName: -> AppConfig.theme.site_name
    user:     -> Session.user()
    helpLink: -> UserHelpService.helpLink()
    showHelp: -> AppConfig.features.app.help_link

</script>

<template lang="pug">
v-list(dense)
  v-list-item.user-dropdown__list-item-button--profile(to="/profile")
    v-list-item-avatar
      v-icon mdi-account
    v-list-item-content
      v-list-item-title(v-t="'user_dropdown.edit_profile'")
  v-list-item.user-dropdown__list-item-button--email-settings(to="/email_preferences")
    v-list-item-avatar
      v-icon mdi-settings
    v-list-item-content
      v-list-item-title(v-t="'user_dropdown.email_settings'")
  v-list-item(v-if="showHelp", :href="helpLink", target="_blank")
    v-list-item-avatar
      v-icon mdi-help-circle-outline
    v-list-item-content
      v-list-item-title(v-t="'user_dropdown.help'")
  v-list-item(to="/contact")
    v-list-item-avatar
      v-icon mdi-email-outline
    v-list-item-content
      v-list-item-title(v-t="{path: 'user_dropdown.contact_site_name', args: {site_name: siteName}}")
  v-list-item(@click="signOut()")
    v-list-item-avatar
      v-icon mdi-exit-to-app
    v-list-item-content
      v-list-item-title(v-t="'user_dropdown.sign_out'")
</template>
