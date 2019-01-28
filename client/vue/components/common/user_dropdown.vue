<script lang="coffee">
AppConfig       = require 'shared/services/app_config'
Session         = require 'shared/services/session'
UserHelpService = require 'shared/services/user_help_service'

module.exports =
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
  v-btn(icon slot="activator", :aria-label="$t('user_dropdown.button_label')")
    v-icon mdi-dots-vertical
  v-list
    v-list-tile(to="/profile")
      v-list-tile-content(v-t="'user_dropdown.edit_profile'")
      v-list-tile-avatar
        v-icon mdi-account
    v-list-tile(to="/email_settings")
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
</template>
