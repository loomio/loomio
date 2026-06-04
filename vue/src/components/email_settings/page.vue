<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AppConfig      from '@/shared/services/app_config';
import { I18n } from '@/i18n';
import { pick, filter } from 'lodash-es';
import UserService from '@/shared/services/user_service';
import Flash from '@/shared/services/flash';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],

  data() {
    return {
      newsletterEnabled: AppConfig.newsletterEnabled,
      user: null,
      groups: [],
      memberships: [],
      loading: false,
      allGroupsVolume: null
    };
  },
  created() {
    this.init();
    EventBus.$on('signedIn', this.init);
    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: store => {
        const user = Session.user();
        this.memberships = user.groups().map((g) => user.membershipFor(g));
      }
    });
  },
  beforeDestroy() {
    return EventBus.$off('signedIn', this.init);
  },

  mounted() {
    return EventBus.$emit('currentComponent', { titleKey: 'email_settings_page.header', page: 'emailSettingsPage'});
  },

  methods: {
    submit() {
      Records.users.updateProfile(this.user).then(() => {
        Flash.custom(I18n.global.t('email_settings_page.messages.updated'), 'success', 4000);
      }).catch(error => true);
    },

    init() {
      if (!Session.isSignedIn() && (Session.user().restricted == null)) { return; }
      Records.users.findOrFetchGroups();
      Session.user().attributeNames.push('unsubscribeToken');
      this.originalUser = Session.user();
      this.user = Session.user().clone();
    },

    groupVolume(group) {
      return group.membershipFor(Session.user()).volume;
    },

    changeDefaultMembershipVolume() {
      EventBus.$emit('openModal', {
        component: 'ChangeVolumeForm',
        props: { model: Session.user() }
      });
    },

    membershipVolumeChanged(membership) {
      this.loading = true
      membership.saveVolume(membership.volume, false).finally(() => {
        Flash.custom(I18n.global.t('email_settings_page.messages.updated'), 'success', 500);
        this.loading = false
      });
    },
    allGroupsVolumeChanged(){
      if (this.allGroupsVolume == null) return;

      this.loading = true
      Session.user().saveVolume(this.allGroupsVolume, true).finally(() => {
        Flash.custom(I18n.global.t('email_settings_page.messages.updated'), 'success', 500);
        this.allGroupsVolume = null;
        this.loading = false
      });
    }
  },
  computed: {
    emailDays() {
      return [
        {value: null, title: this.$t('email_settings_page.never')},
        {value: 7, title: this.$t('email_settings_page.every_day')},
        {value: 8, title: this.$t('email_settings_page.every_second_day')},
        {value: 1, title: this.$t('email_settings_page.monday')},
        {value: 2, title: this.$t('email_settings_page.tuesday')},
        {value: 3, title: this.$t('email_settings_page.wednesday')},
        {value: 4, title: this.$t('email_settings_page.thursday')},
        {value: 5, title: this.$t('email_settings_page.friday')},
        {value: 6, title: this.$t('email_settings_page.saturday')},
        {value: 0, title: this.$t('email_settings_page.sunday')}
      ];
    },
    actions() { return filter(pick(UserService.actions(Session.user(), this), ['deactivate_user']), action => action.canPerform()); },

    defaultSettingsDescription() {
      return `email_settings_page.default_settings.${Session.user().defaultMembershipVolume}_description`;
    }
  }
};
</script>

<template lang="pug">
v-main
  v-container.email-settings-page.max-width-1024.px-0.px-sm-3(v-if='user')

    v-card.mb-4(v-if="user.deactivatedAt")
      v-card-text
        p(v-t="'email_settings_page.account_deactivated'")

    v-card.mb-4(v-if="!user.deactivatedAt")
      v-card-text
        v-checkbox#mentioned-email.email-settings-page__mentioned(v-model='user.emailWhenMentioned')
          template(v-slot:label)
            div
              span(v-t="'email_settings_page.mentioned_label'")
              br
              span.text-medium-emphasis.text-body-small(v-t="'email_settings_page.mentioned_description'")
        v-checkbox#on-participation-email.email-settings-page__on-participation(v-model='user.emailOnParticipation')
          template(v-slot:label)
            div
              span(v-t="'email_settings_page.on_participation_label'")
              br
              span.text-medium-emphasis.text-body-small(v-t="'email_settings_page.on_participation_description'")
        .text-body-large
          span(v-t="'email_settings_page.email_catch_up_day'")
        p.text-medium-emphasis.pb-4(v-t="'email_settings_page.daily_summary_description'")
        v-select#email-catch-up-day(
          solo
          :items="emailDays"
          :label="$t('email_settings_page.email_catch_up_day')"
          v-model="user.emailCatchUpDay")
        //- v-checkbox#daily-summary-email.email-settings-page__daily-summary(v-model='user.emailCatchUp')
        //-   div(slot="label")
        //-     strong(v-t="'email_settings_page.daily_summary_label'")
        //-     .email-settings-page__input-description(v-t="'email_settings_page.daily_summary_description'")
      v-card-actions
        help-btn(path="en/user_manual/users/email_settings/#user-email-settings")
        v-spacer
        v-btn.email-settings-page__update-button(color="primary" @click="submit" variant="tonal")
          span(v-t="'email_settings_page.update_settings'")

    v-card.mb-4(title="Group notifications" subtitle="Change when you get emailed about activity in your groups")
      v-card-text
        .text-body-large.pb-2(v-t="'change_volume_form.what_the_options_mean'")

        .text-title-small.pb-1(v-t="'change_volume_form.quiet_desc'")
        .text-body-medium.pb-4.text-medium-emphasis(v-t="'change_volume_form.quiet_explained'")

        .text-title-small.pb-1(v-t="'change_volume_form.normal_desc'")
        .text-body-medium.pb-4.text-medium-emphasis(v-t="'change_volume_form.normal_explained'")

        .text-title-small.pb-1(v-t="'change_volume_form.loud_desc'")
        .text-body-medium.pb-4.text-medium-emphasis(v-t="'change_volume_form.loud_explained'")
      v-overlay(persistent :model-value="loading" class="align-center justify-center")
        v-progress-circular(color="primary" size="64" indeterminate)


      v-table
        thead
          tr
            th.text-left(v-t="'common.group'")
            th.text-left(v-t="'email_settings_page.send_email'")
        tbody
          tr
            td
              span(v-t="'sidebar.all_groups'")
            td.text-left
              .my-select-wrapper
                select.my-select(:disabled="loading" v-model="allGroupsVolume" @change="allGroupsVolumeChanged()")
                  option(:value="null")
                  option(v-for="volume in ['quiet', 'normal', 'loud']" :value="volume")
                    span(v-t="'change_volume_form.'+volume+'_desc'")
          tr(v-for="membership in memberships" :key="membership.id")
            td {{membership.group().fullName}}
            td.text-left
              .my-select-wrapper
                select.my-select(:disabled="loading" v-model="membership.volume" @change="membershipVolumeChanged(membership)")
                  option(v-for="volume in ['quiet', 'normal', 'loud']" :value="volume" :selected="membership.volume == volume")
                    span(v-t="'change_volume_form.'+volume+'_desc'")

    v-card(:title="$t('email_settings_page.deactivate_header')")
      v-card-text
        p(v-t="'email_settings_page.deactivate_description'")
        v-list
          v-list-item(v-for="(action, key) in actions" :key="key" @click="action.perform()")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title(v-t="action.name")
</template>

<style lang="css">
.my-select-wrapper {
  position: relative;
  display: inline-block;
  width: 100%;
}

.my-select {
  width: 100%;
  height: 32px;               /* precise compact height */
  padding: 0 32px 0 8px;      /* tighter spacing */

  font-size: 14px;            /* compact uses slightly smaller text */
  line-height: 32px;
  cursor: pointer;

  border: 1px solid rgba(var(--v-theme-on-surface), 0.38);
  border-radius: 6px;
  background-color: rgb(var(--v-theme-surface));
  color: rgb(var(--v-theme-on-surface));

  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;

  transition: border-color .18s ease, box-shadow .18s ease;
}

/* Chevron (on wrapper, not select!) */
.my-select-wrapper::after {
  content: "";
  position: absolute;
  right: 8px;                 /* inner padding alignment */
  top: 50%;
  width: 12px;
  height: 12px;
  transform: translateY(-50%);
  pointer-events: none;

  background-color: currentColor;
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' stroke='black' fill='none' stroke-width='2.25' viewBox='0 0 24 24'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' stroke='black' fill='none' stroke-width='2.25' viewBox='0 0 24 24'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
  mask-size: contain;
  mask-repeat: no-repeat;
}

/* Hover / Focus to match compact v-text-field */
.my-select:hover {
  border-color: rgba(var(--v-theme-on-surface), 0.60);
}

.my-select:focus {
  border-color: rgb(var(--v-theme-primary));
  outline: none;
  box-shadow: 0 0 0 2px rgba(var(--v-theme-primary), 0.25); /* slightly smaller ring for compact */
}

/* Placeholder dimming */
.my-select option[disabled][value=""] {
  color: rgba(var(--v-theme-on-surface), 0.45);
}


</style>
