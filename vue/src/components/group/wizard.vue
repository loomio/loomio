<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import AppConfig      from '@/shared/services/app_config'

export default
  props:
    group: Object
    close: Function

  created: ->
    @group.fetchToken()

  methods:
    openEditProfileForm: ->
      openModal
        component: 'GroupForm'
        props:
          group: @group.clone()

    openInvitePeopleForm: ->
      openModal
        component: 'AnnouncementForm'
        props:
          announcement: Records.announcements.buildFromModel(@group.targetModel())

    openInstallSlackModal: ->
      openModal
        component: 'InstallSlackModal'
        props:
          group: @group
          preventClose: true

    openInstallTeamsModal: ->
      openModal
        component: 'InstallMicrosoftTeamsModal'
        props:
          group: @group
          preventClose: true

    openStartThreadModal: ->
      openModal
        component: 'DiscussionForm'
        props:
          discussion: Records.discussions.build(groupId: @group.id)

</script>
<template lang="pug">
v-carousel.group-wizard
  v-carousel-item(key='group_wizard.setup_profile')
    v-card(height="100%" color="primary")
      v-card-title
        h1.headline(v-t="'group_wizard.setup_profile'")
      v-card-text
        span(v-t="'group_wizard.setup_profile_description'")
      v-card-actions
        v-btn(color="accent" @click="openEditProfileForm()" v-t="'group_wizard.do_it'")

  v-carousel-item(key='group_wizard.invite_people')
    v-card(height="100%" color="primary")
      v-card-title
        h1.headline(v-t="'group_wizard.invite_people'")
      v-card-text
        span(v-t="'group_wizard.invite_people_description'")
      v-card-actions
        v-btn(color="accent" @click="openInvitePeopleForm()" v-t="'group_page.invite_people'")
        shareable-link-modal(:group="group" :hasToken="true")

  v-carousel-item(key='group_wizard.setup_integrations')
    v-card(height="100%" color="primary")
      v-card-title
        h1.headline(v-t="'group_wizard.setup_integrations'")
      v-card-text
        span(v-t="'group_wizard.setup_integrations_description'")
      v-card-actions
        v-btn(color="accent" @click="openInstallSlackModal()" v-t="'install_slack.modal_title'")
        v-btn(color="accent" @click="openInstallTeamsModal()" v-t="'install_microsoft.card.install_microsoft'")

  v-carousel-item(key='group_wizard.start_thread')
    v-card(height="100%" color="primary")
      v-card-title
        h1.headline(v-t="'group_wizard.start_thread'")
      v-card-text
        span(v-t="'group_wizard.start_thread_description'")
      v-card-actions
        v-btn(color="accent" @click="openStartThreadModal()" v-t="'group_wizard.do_it'")
</template>
