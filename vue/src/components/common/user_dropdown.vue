<script lang="coffee">
import AppConfig       from '@/shared/services/app_config'
import Session         from '@/shared/services/session'
import Records         from '@/shared/services/records'
import UserHelpService from '@/shared/services/user_help_service'

export default
  methods:
    signOut: ->
      Session.signOut()

  methods:
    togglePinned: ->
      if @user.experiences['sidebar']
        Records.users.removeExperience('sidebar')
      else
        Records.users.saveExperience('sidebar')

  computed:
    siteName: -> AppConfig.theme.site_name
    user:     -> Session.user()
    helpLink: -> UserHelpService.helpLink()
    showHelp: -> AppConfig.features.app.help_link

</script>

<template lang="pug">
div
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
      v-icon mdi-settings
  v-list-item(v-if="showHelp", :href="helpLink", target="_blank" dense)
    v-list-item-title(v-t="'user_dropdown.help'")
    v-list-item-icon
      v-icon mdi-help-circle-outline
  v-list-item(to="/contact" dense)
    v-list-item-title(v-t="{path: 'user_dropdown.contact_site_name', args: {site_name: siteName}}")
    v-list-item-icon
      v-icon mdi-email-outline
  v-list-item(@click="signOut()" dense)
    v-list-item-title(v-t="'user_dropdown.sign_out'")
    v-list-item-icon
      v-icon mdi-exit-to-app
</template>
