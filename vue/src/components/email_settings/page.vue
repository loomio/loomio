<script setup lang="js">
import { computed, onMounted, onUnmounted, ref } from 'vue';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import { I18n } from '@/i18n';
import { pick, filter } from 'lodash-es';
import UserService from '@/shared/services/user_service';
import Flash from '@/shared/services/flash';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { useCurrentUserGroups } from '@/composables/useCurrentUserGroups';
import PushNotificationsSettingsCard from '@/components/push_notifications/settings_card';
import { notificationVolumeOptionTitleKey } from '@/shared/helpers/notification_volume_options';

const { watchRecords } = useWatchRecords();
const { loadGroups } = useCurrentUserGroups();

const user = ref(null);
const memberships = ref([]);
const loading = ref(false);
const allGroupsVolumeEmail = ref(null);
const allGroupsVolumePush = ref(null);

const catchUpEnabled = computed(() => user.value?.emailCatchUpDay != null);

const emailDays = computed(() => [
  {value: null, title: I18n.global.t('email_settings_page.never')},
  {value: 7, title: I18n.global.t('email_settings_page.every_day')},
  {value: 8, title: I18n.global.t('email_settings_page.every_second_day')},
  {value: 1, title: I18n.global.t('email_settings_page.monday')},
  {value: 2, title: I18n.global.t('email_settings_page.tuesday')},
  {value: 3, title: I18n.global.t('email_settings_page.wednesday')},
  {value: 4, title: I18n.global.t('email_settings_page.thursday')},
  {value: 5, title: I18n.global.t('email_settings_page.friday')},
  {value: 6, title: I18n.global.t('email_settings_page.saturday')},
  {value: 0, title: I18n.global.t('email_settings_page.sunday')}
]);

const actions = computed(() => filter(
  pick(UserService.actions(Session.user(), { $t: I18n.global.t }), ['deactivate_user']),
  action => action.canPerform()
));

function submit() {
  Records.users.updateProfile(user.value).then(() => {
    Flash.custom(I18n.global.t('email_settings_page.messages.updated'), 'success', 4000);
  }).catch(() => true);
}

function init() {
  if (!Session.isSignedIn() && (Session.user().restricted == null)) { return; }
  loadGroups();
  Session.user().attributeNames.push('unsubscribeToken');
  user.value = Session.user().clone();
}

function volumeOptionLabel(volume, channel) {
  return I18n.global.t(notificationVolumeOptionTitleKey(volume, channel, catchUpEnabled.value));
}

function membershipVolumeChanged(membership) {
  loading.value = true;
  membership.saveVolume(membership.volumeEmail, membership.volumePush, false).finally(() => {
    Flash.custom(I18n.global.t('email_settings_page.messages.updated'), 'success', 500);
    loading.value = false;
  });
}

function allGroupsVolumeChanged(channel) {
  const volumeEmail = channel === 'email' ? allGroupsVolumeEmail.value : null;
  const volumePush = channel === 'push' ? allGroupsVolumePush.value : null;
  if (volumeEmail == null && volumePush == null) return;

  loading.value = true;
  Session.user().saveVolume(volumeEmail, volumePush, true).finally(() => {
    Flash.custom(I18n.global.t('email_settings_page.messages.updated'), 'success', 500);
    if (channel === 'email') allGroupsVolumeEmail.value = null;
    if (channel === 'push') allGroupsVolumePush.value = null;
    loading.value = false;
  });
}

init();
EventBus.$on('signedIn', init);

watchRecords({
  collections: ['groups', 'memberships'],
  query: () => {
    const currentUser = Session.user();
    memberships.value = currentUser.groups().map(group => currentUser.membershipFor(group));
  }
});

onMounted(() => {
  EventBus.$emit('currentComponent', { titleKey: 'email_settings_page.header', page: 'emailSettingsPage'});
});

onUnmounted(() => {
  EventBus.$off('signedIn', init);
});
</script>

<template lang="pug">
v-main
  v-container.email-settings-page.max-width-1024.px-0.px-sm-3(v-if='user')

    push-notifications-settings-card

    v-card.mb-4(v-if="user.deactivatedAt")
      v-card-text
        p {{ $t('email_settings_page.account_deactivated') }}

    v-card.email-settings-page__digest-card.mb-4(v-if="!user.deactivatedAt")
      v-card-text

        .text-body-large
          span {{ $t('email_settings_page.catch_up_email') }}
        p.text-medium-emphasis.pb-4 {{ $t('email_settings_page.catch_up_email_description') }}
        v-select#digest-email-day(
          solo
          :items="emailDays"
          :label="$t('email_settings_page.catch_up_email')"
          v-model="user.emailCatchUpDay")

      v-card-actions
        help-btn(path="en/user_manual/users/email_settings#notification-settings")
        v-spacer
        v-btn.email-settings-page__update-button(color="primary" @click="submit" variant="tonal")
          span {{ $t('email_settings_page.update_settings') }}

    v-card.email-settings-page__group-notifications-card.mb-4(:title="$t('email_settings_page.group_notifications')" :subtitle="$t('email_settings_page.group_notifications_description')")
      v-card-text
        .text-body-large.pb-1 {{ $t('change_volume_form.how_do_you_want_to_stay_updated') }}
        .text-body-medium.text-medium-emphasis {{ $t('email_settings_page.choose_email_and_push_updates') }}
      v-overlay(persistent :model-value="loading" class="align-center justify-center")
        v-progress-circular(color="primary" size="64" indeterminate)


      v-table
        thead
          tr
            th.text-left {{ $t('common.group') }}
            th.text-left {{ $t('change_volume_form.email_channel') }}
            th.text-left {{ $t('change_volume_form.push_channel') }}
        tbody
          tr
            td
              span {{ $t('sidebar.all_groups') }}
            td.text-left
              .my-select-wrapper
                select.my-select(:disabled="loading" v-model="allGroupsVolumeEmail" @change="allGroupsVolumeChanged('email')")
                  option(:value="null")
                  option(v-for="volume in ['quiet', 'normal', 'loud']" :value="volume") {{ volumeOptionLabel(volume, 'email') }}
            td.text-left
              .my-select-wrapper
                select.my-select(:disabled="loading" v-model="allGroupsVolumePush" @change="allGroupsVolumeChanged('push')")
                  option(:value="null")
                  option(v-for="volume in ['quiet', 'normal', 'loud']" :value="volume") {{ volumeOptionLabel(volume, 'push') }}
          tr(v-for="membership in memberships" :key="membership.id")
            td {{membership.group().fullName}}
            td.text-left
              .my-select-wrapper
                select.my-select(:disabled="loading" v-model="membership.volumeEmail" @change="membershipVolumeChanged(membership)")
                  option(v-for="volume in ['quiet', 'normal', 'loud']" :value="volume" :selected="membership.volumeEmail == volume") {{ volumeOptionLabel(volume, 'email') }}
            td.text-left
              .my-select-wrapper
                select.my-select(:disabled="loading" v-model="membership.volumePush" @change="membershipVolumeChanged(membership)")
                  option(v-for="volume in ['quiet', 'normal', 'loud']" :value="volume") {{ volumeOptionLabel(volume, 'push') }}

    v-card.email-settings-page__deactivate-card(v-if="actions.length" :title="$t('email_settings_page.deactivate_header')")
      v-card-text
        p {{ $t('email_settings_page.deactivate_description') }}
        v-list
          v-list-item(v-for="(action, key) in actions" :key="key" @click="action.perform()")
            template(v-slot:prepend)
              common-icon(:name="action.icon")
            v-list-item-title {{ $t(action.name) }}
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
