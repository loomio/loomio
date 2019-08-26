<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import AppConfig      from '@/shared/services/app_config'

import WizardPanel from '@/components/group/wizard_panel'

export default
  components:
    WizardPanel: WizardPanel

  props:
    group: Object
    close: Function
    showWelcome: {
      default: true
      type: Boolean
    }

  data: ->
    openModals:
      editGroup: false
      invitePeople: false
      installSlack: false
      installTeams: false
      startThread: false

  created: ->
    @group.fetchToken()

  computed:
    newDiscussion: -> Records.discussions.build(groupId: @group.id)
    announcement: -> Records.announcements.buildFromModel(@group.targetModel())

  methods:
    closeFor: (name) ->
      => @openModals[name] = false
</script>
<template lang="pug">
v-carousel.group-wizard(:continuous="false")
  wizard-panel(v-if="showWelcome" title="group_wizard.welcome")
    v-card-text
      span(v-t="'group_wizard.welcome_description'")

  wizard-panel(title="group_wizard.setup_profile")
    v-card-text
      span(v-t="'group_wizard.setup_profile_description'")
    v-card-actions
      .edit-group-button
        v-btn(color='accent' @click="openModals.editGroup = true" v-t="'group_wizard.do_it'")
        v-dialog(v-model="openModals.editGroup" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
          group-form(:group="group" :close="closeFor('editGroup')")

  wizard-panel(title="group_wizard.invite_people")
    v-card-text
      span(v-t="'group_wizard.invite_people_description'")
    v-card-actions
      .invite-button
        v-btn(color='accent' @click="openModals.invitePeople = true" v-t="'group_page.invite_people'")
        v-dialog(v-model="openModals.invitePeople" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
          announcement-form(:announcement="announcement" :close="closeFor('invitePeople')")
      shareable-link-modal(:group="group")

  wizard-panel(title="group_wizard.setup_integrations")
    v-card-text
      span(v-t="'group_wizard.setup_integrations_description'")
    v-card-actions
      .invite-button
        v-btn(color='accent' @click="openModals.installSlack = true" v-t="'install_slack.modal_title'" :disabled="group.groupIdentityFor('slack')")
        v-dialog(v-model="openModals.installSlack" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
          install-slack-modal(:group="group" :close="closeFor('installSlack')" :preventClose="true")
      .invite-button
        v-btn(color='accent' @click="openModals.installTeams = true" v-t="'install_microsoft.card.install_microsoft'" :disabled="group.groupIdentityFor('microsoft')")
        v-dialog(v-model="openModals.installTeams" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
          install-microsoft-teams-modal(:group="group" :close="closeFor('installTeams')")

  wizard-panel(title="group_wizard.setup_integrations")
    v-card-text
      span(v-t="'group_wizard.start_thread_description'")
    v-card-actions
      .edit-group-button
      v-btn(color='accent' @click="openModals.startThread = true" v-t="'group_wizard.do_it'")
      v-dialog(v-model="openModals.startThread" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
        discussion-form(:discussion="newDiscussion" :close="closeFor('startThread')")
</template>
