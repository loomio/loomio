<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import UserService    from '@/shared/services/user_service';
import Flash   from '@/shared/services/flash';
import { includes, uniq, debounce, pickBy } from 'lodash-es';
import {exact} from '@/shared/helpers/format_time';
import { I18n, loadLocaleMessages } from '@/i18n';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [WatchRecords, UrlFor],
  data() {
    return {
      user: null,
      originalUser: null,
      existingEmails: [],
      currentTime: new Date(),
      timeZones: []
    };
  },

  created() {
    setInterval((() => { this.currentTime = new Date(); }), 10000);
    this.init();
    EventBus.$emit('currentComponent', { titleKey: 'profile_page.edit_profile', page: 'profilePage'});
    EventBus.$on('updateProfile', this.init);
    EventBus.$on('signedIn', this.init);
  },

  beforeDestroy() {
    EventBus.$off('updateProfile', this.init);
    EventBus.$off('signedIn', this.init);
  },

  computed: {
    showHelpTranslate() { return AppConfig.features.app.help_link; },
    availableLocales() { return AppConfig.locales.map(h => { return {title: h.name, value: h.key} }) ; },
    dateTimeFormats() {
      const observeLocale = this.user.selectedLocale; // tell vue this matters
      return 'iso day_iso abbr day_abbr'.split(' ').map(pref => {
        return {value: pref, title: exact(this.currentTime, this.user.timeZone, pref)};
      });
    },
    actions() { return pickBy(UserService.actions(Session.user(), this), action => action.canPerform()) },
    emailExists() { return includes(this.existingEmails, this.user.email); }
  },

  watch: {
    'user.autodetectTimeZone'(val) {
      if (val) {this.user.timeZone = AppConfig.timeZone }
    },

    'user.selectedLocale'(val) {
      this.fetchTimeZones();
    }
  },

  methods: {
    init() {
      if (!Session.isSignedIn()) { return; }
      this.originalUser = Session.user();
      this.user = this.originalUser.clone();
      this.fetchTimeZones();
      loadLocaleMessages(I18n, this.user.locale);
    },

    fetchTimeZones() {
      const locale = this.user.selectedLocale || this.user.locale
      Records.fetch({path: 'profile/all_time_zones', params: {selected_locale: locale}}).then(data => {
        this.timeZones = data
      })
    },

    changePicture() {
      openModal({component: 'ChangePictureForm'});
    },

    changePassword() {
      this.openChangePasswordModal(this.user);
    },

    openDeleteUserModal() {
      this.isDeleteUserModalOpen = true;
    },

    closeDeleteUserModal() {
      this.isDeleteUserModalOpen = false;
    },

    openSendVerificationModal() {
      openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: () => Records.users.sendMergeVerificationEmail(this.user.email),
            text: {
              title:    'merge_accounts.modal.title',
              raw_helptext: this.$t('merge_accounts.modal.helptext', {sourceEmail: this.originalUser.email, targetEmail: this.user.email}),
              submit:   'merge_accounts.modal.submit',
              flash:    'merge_accounts.modal.flash'
            }
          }
        }
      });
    },

    checkEmailExistence: debounce(function() {
      if (this.originalUser.email === this.user.email) { return; }
      Records.users.checkEmailExistence(this.user.email).then(res => {
        if (res.exists) {
          this.existingEmails = uniq(this.existingEmails.concat([res.email]));
        }
      });
    } , 250),

    submit() {
      Records.users.updateProfile(this.user).then(() => {
        Flash.success('profile_page.messages.updated');
        this.init();
      }).catch(() => true);
    }
  }
};

</script>
<template lang="pug">
v-main
  v-container.profile-page.max-width-1024.px-0.px-sm-3
    loading(v-if='!user')
    div(v-if='user')
      v-card(:title="$t('profile_page.edit_profile')")
        v-card-text
          .profile-page__details
            .d-sm-flex
              .flex-fill
                v-text-field.profile-page__name-input(:label="$t('profile_page.name_label')" required v-model="user.name")
                validation-errors(:subject='user', field='name')

                v-text-field#user-username-field.profile-page__username-input(:label="$t('profile_page.username_label')" required v-model="user.username")
                validation-errors(:subject='user', field='username')

                //- span existingEmails: {{ existingEmails }}
                v-text-field#user-email-field.profile-page__email-input(:label="$t('profile_page.email_label')" required v-model='user.email' @keyup="checkEmailExistence")
                validation-errors(:subject='user', field='email')
                .profile-page__email-taken(v-if="emailExists")
                  span.email-taken-message(v-t="'merge_accounts.email_taken'")
                  space
                  a.email-taken-find-out-more(@click="openSendVerificationModal" v-t="'merge_accounts.find_out_more'")

              .profile-page__avatar.d-flex.flex-column.justify-center.align-center.mx-12.mb-4(@click="changePicture()")
                user-avatar.mb-4(:user='originalUser' :size='192' :no-link="true")
                v-btn(color="primary" variant="tonal" @click="changePicture")
                  span(v-t="'profile_page.change_picture_link'")

            lmo-textarea(
              :model='user'
              field="shortBio"
              :label="$t('profile_page.short_bio_label')"
              :placeholder="$t('profile_page.short_bio_placeholder')")
            validation-errors(:subject='user', field='shortBio')

            v-text-field#user-location-field.profile-page__location-input(
              v-model='user.location'
              :label="$t('profile_page.location_label')"
              :placeholder="$t('profile_page.location_placeholder')")

            v-select#user-date-time-format-field(
              :label="$t('profile_page.date_time_pref_label')"
              :items="dateTimeFormats"
              v-model="user.dateTimePref")
            validation-errors(:subject='user', field='dateTimeFormat')

            v-select#user-locale-field(
              :label="$t('profile_page.locale_label')"
              :items="availableLocales"
              v-model="user.selectedLocale")
            validation-errors(:subject='user', field='selectedLocale')

            v-checkbox(v-model="user.autodetectTimeZone" :label="$t('profile_page.autodetect_time_zone')")
            v-select(v-model="user.timeZone" :items="timeZones" :label="$t('common.time_zone')"  item-title="title" item-value="value" :disabled="user.autodetectTimeZone")

            v-checkbox(v-model="user.bot" :label="$t('profile_page.account_is_bot')")
            v-alert(v-if="user.bot" type="warning")
              span(v-t="'profile_page.bot_account_warning'")
        v-card-actions.profile-page__update-account
          help-btn(path="en/user_manual/users/user_profile")
          v-spacer
          v-btn.profile-page__update-button(
            color="primary"
            variant="elevated"
            @click='submit()'
            :disabled='emailExists'
            :loading="user.processing"
          )
            span(v-t="'profile_page.update_profile'")

      v-card.profile-page-card.mt-4
        v-list(lines="two")
          v-list-item(v-for="(action, key) in actions" :key="key"  @click="action.perform()" :class="'user-page__' + key")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title(v-t="action.name")
            v-list-item-subtitle(v-if="action.subtitle" v-t="action.subtitle")

</template>

<style lang="sass">
.profile-page__avatar
  cursor: pointer
.email-taken-message
  color: red
</style>
