<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import AppConfig      from '@/shared/services/app_config'

import WizardPanel from '@/components/common/wizard_panel'

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
      changePicture: false
      setupProfile: false

  created: ->
    Records.users.saveExperience("userWizard")

  methods:
    closeFor: (name) ->
      => @openModals[name] = false
</script>
<template lang="pug">
v-carousel.group-wizard(:continuous="false")
  wizard-panel(v-if="showWelcome" title="group_wizard.welcome")
    v-card-text
      span(v-t="'user_wizard.welcome_description'")

  wizard-panel(title="user_wizard.change_picture")
    v-card-text
      span(v-t="'user_wizard.change_picture_description'")
    v-card-actions
      .edit-group-button
        v-btn(color='accent' @click="openModals.changePicture = true" v-t="'group_wizard.do_it'")
        v-dialog(v-model="openModals.changePicture" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
          change-picture-form(:close="closeFor('changePicture')")

</template>
