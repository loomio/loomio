<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { uniq, compact, concat, sortBy, map, pick } from 'lodash'
import UserService from '@/shared/services/user_service'
import Flash from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

export default
  mixins: [ChangeVolumeModalMixin]
  data: ->
    newsletterEnabled: AppConfig.newsletterEnabled
    user: null
    groups: []
  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()
    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        groups = Session.user().groups()
        user = Session.user()
        @groups = sortBy groups, 'fullName'

  mounted: ->
    EventBus.$emit 'currentComponent', { titleKey: 'email_settings_page.header', page: 'emailSettingsPage'}

  methods:
    submit: ->
      Records.users.updateProfile(@user)
      .then =>
        Flash.success 'email_settings_page.messages.updated'
      .catch onError(@user)

    init: ->
      return unless Session.isSignedIn() or Session.user().restricted?
      Session.user().attributeNames.push('unsubscribeToken')
      @originalUser = Session.user()
      @user = Session.user().clone()

    groupVolume: (group) ->
      group.membershipFor(Session.user()).volume

    changeDefaultMembershipVolume: ->
      @openChangeVolumeModal(Session.user())

    editSpecificGroupVolume: (group) ->
      @openChangeVolumeModal(Session.user())
  computed:
    actions: -> pick UserService.actions(Session.user(), @), ['reactivate_user', 'deactivate_user']

    defaultSettingsDescription: ->
      "email_settings_page.default_settings.#{Session.user().defaultMembershipVolume}_description"
</script>

<template lang="pug">
v-content
  v-container.email-settings-page.max-width-1024(v-if='user')

    v-card.mb-4(v-if="user.deactivatedAt")
      //- v-card-title
      //-   h1.headline(v-t="'email_settings_page.header'")
      v-card-text
        p(v-t="'email_settings_page.account_deactivated'")

    v-card.mb-4(v-if="!user.deactivatedAt")
      //- v-card-title
      //-   h1.headline(v-t="'email_settings_page.header'")
      v-card-text
        .email-settings-page__email-settings
          .email-settings-page__global-settings
            form
              .email-settings-page__global-settings
                v-checkbox#daily-summary-email.md-checkbox--with-summary.email-settings-page__daily-summary(v-model='user.emailCatchUp')
                  div(slot="label")
                    strong(v-t="'email_settings_page.daily_summary_label'")
                    .email-settings-page__input-description(v-t="'email_settings_page.daily_summary_description'")
                v-checkbox#on-participation-email.md-checkbox--with-summary.email-settings-page__on-participation(v-model='user.emailOnParticipation')
                  div(slot="label")
                    strong(v-t="'email_settings_page.on_participation_label'")
                    .email-settings-page__input-description(v-t="'email_settings_page.on_participation_description'")
                v-checkbox#mentioned-email.md-checkbox--with-summary.email-settings-page__mentioned(v-model='user.emailWhenMentioned')
                  div(slot="label")
                    strong(v-t="'email_settings_page.mentioned_label'")
                    .email-settings-page__input-description(v-t="'email_settings_page.mentioned_description'")
      v-card-actions
        a.email-settings-page__learn-more-link(href='https://help.loomio.org/en/user_manual/users/email_settings/' target='_blank' v-t="'email_settings_page.learn_more'")
        v-spacer
        v-btn.email-settings-page__update-button(color="primary" @click="submit()" v-t="'email_settings_page.update_settings'")

    change-volume-form.mb-4(:model="user" :show-close="false")

    v-card
      v-card-title
        h1.headline(v-t="'email_settings_page.deactivate_header'")
      v-card-text
        p(v-t="'email_settings_page.deactivate_description'")
        v-list
          v-list-item(v-for="(action, key) in actions" :key="key" v-if="action.canPerform()" @click="action.perform()")
            v-list-item-icon
              v-icon {{action.icon}}
            v-list-item-title(v-t="action.name")
</template>
