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
import { includes, uniq, debounce } from 'lodash-es';
import {exact} from '@/shared/helpers/format_time';

export default {
  data() {
    return {
      user: null,
      originalUser: null,
      existingEmails: [],
      currentTime: new Date()
    };
  },

  created() {
    setInterval((() => { this.currentTime = new Date(); }), 10000);
    this.init();
    EventBus.$emit('currentComponent', { titleKey: 'profile_page.edit_profile', page: 'profilePage'});
    EventBus.$on('updateProfile', this.init);
    return EventBus.$on('signedIn', this.init);
  },

  beforeDestroy() {
    EventBus.$off('updateProfile', this.init);
    EventBus.$off('signedIn', this.init);
  },

  computed: {
    showHelpTranslate() { return AppConfig.features.app.help_link; },
    availableLocales() { return AppConfig.locales; },
    dateTimeFormats() {
      const observeLocale = this.user.selectedLocale; // tell vue this matters
      return 'iso day_iso abbr day_abbr'.split(' ').map(pref => {
        return {value: pref, text: exact(this.currentTime, this.user.timeZone, pref)};
      });
    },
    actions() { return UserService.actions(Session.user(), this); },
    emailExists() { return includes(this.existingEmails, this.user.email); }
  },

  methods: {
    init() {
      if (!Session.isSignedIn()) { return; }
      this.originalUser = Session.user();
      this.user = this.originalUser.clone();
      Session.updateLocale(this.user.locale);
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
<template>

<v-main>
  <v-container class="profile-page max-width-1024 px-0 px-sm-3">
    <loading v-if="!user"></loading>
    <div v-if="user">
      <v-card>
        <submit-overlay :value="user.processing"></submit-overlay>
        <v-card-text>
          <v-layout>
            <v-flex class="profile-page__details">
              <v-layout :column="$vuetify.breakpoint.xs">
                <v-flex>
                  <v-text-field class="profile-page__name-input" :label="$t('profile_page.name_label')" required="required" v-model="user.name"></v-text-field>
                  <validation-errors :subject="user" field="name"></validation-errors>
                  <v-text-field class="profile-page__username-input" id="user-username-field" :label="$t('profile_page.username_label')" required="required" v-model="user.username"></v-text-field>
                  <validation-errors :subject="user" field="username"></validation-errors>
                  <v-text-field class="profile-page__email-input" id="user-email-field" :label="$t('profile_page.email_label')" required="required" v-model="user.email" @keyup="checkEmailExistence"></v-text-field>
                  <validation-errors :subject="user" field="email"></validation-errors>
                  <div class="profile-page__email-taken" v-if="emailExists"><span class="email-taken-message" v-t="'merge_accounts.email_taken'"></span>
                    <space></space><a class="email-taken-find-out-more" @click="openSendVerificationModal" v-t="'merge_accounts.find_out_more'"></a>
                  </div>
                </v-flex>
                <div class="profile-page__avatar d-flex flex-column justify-center align-center mx-12" @click="changePicture()">
                  <user-avatar class="mb-4" :user="originalUser" :size="192" :no-link="true"></user-avatar>
                  <v-btn color="accent" @click="changePicture" v-t="'profile_page.change_picture_link'"></v-btn>
                </div>
              </v-layout>
              <lmo-textarea :model="user" field="shortBio" :label="$t('profile_page.short_bio_label')" :placeholder="$t('profile_page.short_bio_placeholder')"></lmo-textarea>
              <validation-errors :subject="user" field="shortBio"></validation-errors>
              <v-text-field class="profile-page__location-input" id="user-location-field" v-model="user.location" :label="$t('profile_page.location_label')" :placeholder="$t('profile_page.location_placeholder')"></v-text-field>
              <v-select id="user-date-time-format-field" :label="$t('profile_page.date_time_pref_label')" :items="dateTimeFormats" v-model="user.dateTimePref"></v-select>
              <validation-errors :subject="user" field="dateTimeFormat"></validation-errors>
              <v-select id="user-locale-field" :label="$t('profile_page.locale_label')" :items="availableLocales" v-model="user.selectedLocale" item-text="name" item-value="key"></v-select>
              <validation-errors :subject="user" field="selectedLocale"></validation-errors>
              <p><span v-t="'common.time_zone'"></span>
                <space></space><span>{{user.timeZone}}</span>
                <space></space>
                <v-tooltip top="top">
                  <template v-slot:activator="{on, attrs}">
                    <common-icon v-bind="attrs" v-on="on" small="small" name="mdi-information-outline"></common-icon>
                  </template><span v-t="'profile_page.updated_on_sign_in'"></span>
                </v-tooltip>
              </p>
              <v-checkbox v-model="user.bot" :label="$t('profile_page.account_is_bot')"></v-checkbox>
              <v-alert v-if="user.bot" type="warning"><span v-t="'profile_page.bot_account_warning'"></span></v-alert>
            </v-flex>
          </v-layout>
        </v-card-text>
        <v-card-actions class="profile-page__update-account">
          <help-link path="en/user_manual/users/user_profile"></help-link>
          <v-spacer></v-spacer>
          <v-btn class="profile-page__update-button" color="primary" @click="submit()" :disabled="emailExists" :loading="user.processing"><span v-t="'profile_page.update_profile'"></span></v-btn>
        </v-card-actions>
      </v-card>
      <v-card class="profile-page-card mt-4">
        <v-list>
          <v-list-item v-for="(action, key) in actions" :key="key" v-if="action.canPerform()" @click="action.perform()" :class="'user-page__' + key">
            <v-list-item-icon>
              <common-icon :name="action.icon"></common-icon>
            </v-list-item-icon>
            <v-list-item-title v-t="action.name"></v-list-item-title>
          </v-list-item>
        </v-list>
      </v-card>
    </div>
  </v-container>
</v-main>
</template>

<style lang="sass">
.profile-page__avatar
  cursor: pointer
.email-taken-message
  color: red
</style>
