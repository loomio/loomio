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
v-menu(offset-y)
  v-btn.user-dropdown__dropdown-button(icon slot="activator", :aria-label="$t('user_dropdown.button_label')")
    v-icon mdi-dots-vertical
  v-list
    v-list-tile
      v-list-tile-content.user-dropdown__user-details
        .user-dropdown__name
          .user-dropdown__user-name.lmo-truncate {{user.name}}
          .user-dropdown__user-username.lmo-truncate @{{user.username}}
      v-list-tile-avatar
        user-avatar(:user="user" size="medium")
    v-list-tile.user-dropdown__list-item-button--profile(to="/profile")
      v-list-tile-content(v-t="'user_dropdown.edit_profile'")
      v-list-tile-avatar
        v-icon mdi-account
    v-list-tile.user-dropdown__list-item-button--email-settings(to="/email_preferences")
      v-list-tile-content(v-t="'user_dropdown.email_settings'")
      v-list-tile-avatar
        v-icon mdi-settings
    v-list-tile(v-if="showHelp", :href="helpLink", target="_blank")
      v-list-tile-content(v-t="'user_dropdown.help'")
      v-list-tile-avatar
        v-icon mdi-help-circle-outline
    v-list-tile(to="/contact")
      v-list-tile-content(v-t="{path: 'user_dropdown.contact_site_name', args: {site_name: siteName}}")
      v-list-tile-avatar
        v-icon mdi-email-outline
    v-list-tile(@click="signOut()")
      v-list-tile-content(v-t="'user_dropdown.sign_out'")
      v-list-tile-avatar
        v-icon mdi-exit-to-app
</template>
