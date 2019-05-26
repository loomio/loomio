<style lang="scss">
.email-settings-page {
  @import 'layout';
  @include lmoRow;
}

.email-settings-page__email-settings {
  @import 'lmo_card';
  @include card;
}

.email-settings-page__specific-group-settings {
  margin-top: 40px;
}

.email-settings-page__group {
  padding: 12px 0 !important;
}

.email-settings-page__learn-more-link {
  @import 'lmo_card';
  @include cardMinorAction;
}
</style>

<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { submitForm }   from '@/shared/helpers/form'
import { uniq, compact, concat, sortBy, map } from 'lodash'


export default
  mixins: [ChangeVolumeModalMixin]
  data: ->
    newsletterEnabled: AppConfig.newsletterEnabled
    user: null
    groups: []
  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()
    EventBus.$emit 'currentComponent', { titleKey: 'email_settings_page.header', page: 'emailSettingsPage'}
    Records.view
      name:"emailSettingsGroups"
      collections: ['groups', 'memberships']
      query: (store) =>
        groups = Session.user().formalGroups()
        user = Session.user()
        @groups = sortBy groups, 'fullName'
  methods:
    init: ->
      return unless Session.isSignedIn() or Session.user().restricted?
      Session.user().attributeNames.push('unsubscribeToken')
      @originalUser = Session.user()
      @user = Session.user().clone()
      @submit = submitForm @, @user,
        submitFn: Records.users.updateProfile
        flashSuccess: 'email_settings_page.messages.updated'

    groupVolume: (group) ->
      group.membershipFor(Session.user()).volume

    changeDefaultMembershipVolume: ->
      @openChangeVolumeModal(Session.user())

    editSpecificGroupVolume: (group) ->
      @openChangeVolumeModal(Session.user())
  computed:
    defaultSettingsDescription: ->
      "email_settings_page.default_settings.#{Session.user().defaultMembershipVolume}_description"
</script>

<template lang="pug">
main.email-settings-page(v-if='user')
  .lmo-page-heading
    h1.lmo-h1-medium(v-t="'email_settings_page.header'")
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
          v-checkbox#email-promotions.md-checkbox--with-summary.email-settings-page__promotions(v-model='user.emailNewsletter', v-if='newsletterEnabled')
            div(slot="label")
              strong(v-t="'email_settings_page.email_newsletter'")
              .email-settings-page__input-description(v-t="'email_settings_page.email_newsletter_description'")
        v-btn.md-primary.md-raised.email-settings-page__update-button(@click="submit()" ng-disabled='isDisabled', v-t="'email_settings_page.update_settings'")
    .email-settings-page__specific-group-settings
      h3.lmo-h3(v-t="'email_settings_page.specific_groups'")
      v-list(class='email-settings-page__groups')
        v-list-tile.email-settings-page__group.lmo-flex.lmo-flex__space-between
          .lmo-box--medium.lmo-margin-right.lmo-flex.lmo-flex__center.lmo-flex__horizontal-center
            i.mdi.mdi-account-multiple-plus.mdi-24px
          .email-settings-page__default-description(v-html="$t(defaultSettingsDescription)")
          v-btn.md-accent.email-settings-page__change-default-link(@click='changeDefaultMembershipVolume()', v-t="'common.action.edit'")
        v-list-tile.email-settings-page__group.lmo-flex.lmo-flex__space-between(v-for='group in groups', key='group.id')
          group-avatar.lmo-margin-right(:group='group', size='medium')
          .email-settings-page__group-details.lmo-flex__grow
            strong.email-settings-page__group-name
              span(v-if='group.isSubgroup()') {{group.parentName()}} -
              span {{group.name}}
            .email-settings-page__membership-volume(v-t="'change_volume_form.' + groupVolume(group) + '_label'")
          .email-settings-page__edit
            v-btn.md-accent.email-settings-page__edit-membership-volume-link(@click='editSpecificGroupVolume(group)', v-t="'email_settings_page.edit'")
      router-link.email-settings-page__learn-more-link(to='https://help.loomio.org/en/user_manual/users/email_settings/', target='_blank', v-t="'email_settings_page.learn_more'")
</template>
