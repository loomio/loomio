<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AppConfig      from '@/shared/services/app_config';
import { sortBy, pick, filter } from 'lodash-es';
import UserService from '@/shared/services/user_service';
import Flash from '@/shared/services/flash';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],

  data() {
    return {
      newsletterEnabled: AppConfig.newsletterEnabled,
      user: null,
      groups: []
    };
  },
  created() {
    this.init();
    EventBus.$on('signedIn', this.init);
    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: store => {
        const groups = Session.user().groups();
        const user = Session.user();
        return this.groups = sortBy(groups, 'fullName');
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
        Flash.success('email_settings_page.messages.updated');
      }).catch(error => true);
    },

    init() {
      if (!Session.isSignedIn() && (Session.user().restricted == null)) { return; }
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

    editSpecificGroupVolume(group) {
      EventBus.$emit('openModal', {
        component: 'ChangeVolumeForm',
        props: { model: Session.user() }
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
      //- v-card-title
      //-   h1.text-h5(tabindex="-1" v-t="'email_settings_page.header'")
      v-card-text
        p(v-t="'email_settings_page.account_deactivated'")

    v-card.mb-4(v-if="!user.deactivatedAt")
      //- v-card-title
      //-   h1.text-h5(tabindex="-1" v-t="'email_settings_page.header'")
      v-card-text
        v-checkbox#mentioned-email.md-checkbox--with-summary.email-settings-page__mentioned(v-model='user.emailWhenMentioned')
          template(v-slot:label)
            div
              span(v-t="'email_settings_page.mentioned_label'")
              br
              span.text-medium-emphasis.text-caption(v-t="'email_settings_page.mentioned_description'")
        v-checkbox#on-participation-email.md-checkbox--with-summary.email-settings-page__on-participation(v-model='user.emailOnParticipation')
          template(v-slot:label)
            div
              span(v-t="'email_settings_page.on_participation_label'")
              br
              span.text-medium-emphasis.text-caption(v-t="'email_settings_page.on_participation_description'")
        .text-subtitle-1
          span(v-t="'email_settings_page.email_catch_up_day'")
        p.text-medium-emphasis.pb-4(v-t="'email_settings_page.daily_summary_description'")
        v-select#email-catch-up-day(
          solo
          :items="emailDays"
          :label="$t('email_settings_page.email_catch_up_day')"
          v-model="user.emailCatchUpDay")
        //- v-checkbox#daily-summary-email.md-checkbox--with-summary.email-settings-page__daily-summary(v-model='user.emailCatchUp')
        //-   div(slot="label")
        //-     strong(v-t="'email_settings_page.daily_summary_label'")
        //-     .email-settings-page__input-description(v-t="'email_settings_page.daily_summary_description'")
      v-card-actions
        help-btn(path="en/user_manual/users/email_settings/#user-email-settings")
        v-spacer
        v-btn.email-settings-page__update-button(color="primary" @click="submit()")
          span(v-t="'email_settings_page.update_settings'")

    change-volume-form.mb-4(:model="user" :show-close="false")

    v-card(:title="$t('email_settings_page.deactivate_header')")
      v-card-text
        p(v-t="'email_settings_page.deactivate_description'")
        v-list
          v-list-item(v-for="(action, key) in actions" :key="key" @click="action.perform()")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title(v-t="action.name")
</template>
