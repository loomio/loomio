<script setup>
import { computed, onMounted, ref, watch } from 'vue';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import PushSubscriptionService from '@/shared/services/push_subscription_service';
import Session from '@/shared/services/session';
import { I18n } from '@/i18n';
import {
  notificationVolumeContextKey,
  notificationVolumeOptionDescriptionKey,
  notificationVolumeOptionTitleKey,
  notificationVolumeTitleKey
} from '@/shared/helpers/notification_volume_options';

const { model, showClose = true } = defineProps({
  model: { type: Object, required: true },
  close: Function,
  showClose: { type: Boolean, default: true }
});

const initialEmail = defaultVolumeEmail();
const initialPush = defaultVolumePush();
const volumeEmail = ref(initialEmail);
const volumePush = ref(initialPush);
const deliveryChannel = ref('email');
const previousEmail = ref(initialEmail === 'quiet' ? 'normal' : initialEmail);
const previousPush = ref(initialPush === 'quiet' ? 'normal' : initialPush);
const applyToAll = ref(model.isA('user'));
const saving = ref(false);
const volumes = ['quiet', 'normal', 'loud'];

const catchUpEnabled = computed(() => Session.user().emailCatchUpDay != null);
const catchUpHintKey = computed(() => {
  switch (Session.user().emailCatchUpDay) {
  case 7:  return 'change_volume_form.catch_up_daily_hint';
  case 8:  return 'change_volume_form.catch_up_every_second_day_hint';
  default: return 'change_volume_form.catch_up_weekly_hint';
  }
});
const contextKey = notificationVolumeContextKey(model);
const titleKey = notificationVolumeTitleKey(model);

const formChanged = computed(() =>
  volumeEmail.value !== initialEmail ||
  volumePush.value !== initialPush ||
  applyToAll.value !== model.isA('user')
);

const pushEnabled = ref(false);
const pushStatusLoaded = ref(false);
const deliveryChannelItems = computed(() => [
  { title: I18n.global.t('change_volume_form.email_channel'), value: 'email' },
  { title: I18n.global.t('change_volume_form.push_channel'), value: 'push' },
  { title: I18n.global.t('change_volume_form.email_and_push_channel'), value: 'email_and_push' }
]);

onMounted(async () => {
  try {
    pushEnabled.value = (await PushSubscriptionService.subscriptions()).length > 0;
    if (pushEnabled.value) deliveryChannel.value = defaultDeliveryChannel();
  } catch (_error) {
    pushEnabled.value = false;
  } finally {
    pushStatusLoaded.value = true;
  }
});

watch(deliveryChannel, channel => {
  if (channel === 'email') {
    if (volumePush.value !== 'quiet') previousPush.value = volumePush.value;
    volumeEmail.value = volumeEmail.value === 'quiet' ? previousEmail.value : volumeEmail.value;
    volumePush.value = 'quiet';
  } else if (channel === 'push') {
    if (volumeEmail.value !== 'quiet') previousEmail.value = volumeEmail.value;
    volumeEmail.value = 'quiet';
    volumePush.value = volumePush.value === 'quiet' ? previousPush.value : volumePush.value;
  } else {
    volumeEmail.value = volumeEmail.value === 'quiet' ? previousEmail.value : volumeEmail.value;
    volumePush.value = volumePush.value === 'quiet' ? previousPush.value : volumePush.value;
  }
});

function defaultVolumeEmail() {
  switch (model.constructor.singular) {
  case 'topic':      return model.readerVolumeEmail;
  case 'membership': return model.volumeEmail;
  case 'user':       return model.volumeEmailDefault;
  default:           return 'normal';
  }
}

function defaultVolumePush() {
  switch (model.constructor.singular) {
  case 'topic':      return model.readerVolumePush;
  case 'membership': return model.volumePush;
  case 'user':       return model.volumePushDefault;
  default:           return 'normal';
  }
}

function defaultDeliveryChannel() {
  const emailActive = catchUpEnabled.value || ['normal', 'loud'].includes(initialEmail);
  const pushActive = ['normal', 'loud'].includes(initialPush);
  if (emailActive && pushActive) return 'email_and_push';
  return pushActive ? 'push' : 'email';
}

function optionTitleKey(volume, channel) {
  return notificationVolumeOptionTitleKey(volume, channel, catchUpEnabled.value);
}

function optionDescriptionKey(volume, channel) {
  return notificationVolumeOptionDescriptionKey(volume, channel, catchUpEnabled.value);
}

async function submit() {
  saving.value = true;
  try {
    await model.saveVolume(
      volumeEmail.value,
      pushEnabled.value ? volumePush.value : undefined,
      applyToAll.value
    );
    Flash.success('change_volume_form.saved');
    EventBus.$emit('closeModal');
  } catch (error) {
    if (error.message === 'push_permission_denied') {
      Flash.error('push_notifications.permission_denied');
    } else if (error.message === 'push_not_supported') {
      Flash.error('push_notifications.not_supported');
    } else {
      Flash.error('common.check_for_errors_and_try_again');
    }
  } finally {
    saving.value = false;
  }
}

</script>

<template lang="pug">
v-card.change-volume-form(
  :class="{ 'change-volume-form--push-enabled': pushEnabled, 'change-volume-form--push-disabled': pushStatusLoaded && !pushEnabled }"
  :title="$t(titleKey)")
  template(v-slot:append)
    dismiss-modal-button(v-if="showClose")
  v-card-text.px-2
    v-select.change-volume-form__delivery-channel.mb-4(
      v-if="pushEnabled"
      hide-details
      v-model="deliveryChannel"
      :items="deliveryChannelItems"
      :label="$t('change_volume_form.delivery_method')")

    .text-body-large.mb-2.pl-4 {{ $t('change_volume_form.how_do_you_want_to_stay_updated') }}

    v-radio-group.mb-4(
      v-if="deliveryChannel !== 'push'"
      hide-details
      v-model="volumeEmail"
      :label="$t('change_volume_form.volume_email_label')")
      v-radio(v-for="volume in volumes" :key="`email-${volume}`" :class="`volume-${volume}`" :value="volume")
        template(v-slot:label)
          div.py-1
            .text-body-medium {{ $t(optionTitleKey(volume, 'email')) }}
            .text-body-small.text-medium-emphasis {{ $t(optionDescriptionKey(volume, 'email'), { context: $t(contextKey) }) }}

    v-radio-group.mb-4(
      v-if="pushEnabled && deliveryChannel !== 'email'"
      hide-details
      v-model="volumePush"
      :label="$t('change_volume_form.volume_push_label')")
      v-radio(v-for="volume in volumes" :key="`push-${volume}`" :class="`volume-${volume}`" :value="volume")
        template(v-slot:label)
          div.py-1
            .text-body-medium {{ $t(optionTitleKey(volume, 'push')) }}
            .text-body-small.text-medium-emphasis {{ $t(optionDescriptionKey(volume, 'push'), { context: $t(contextKey) }) }}

    .text-body-small.text-medium-emphasis.mb-2.pl-4(v-if="catchUpEnabled") {{ $t(catchUpHintKey) }}

    v-checkbox#apply-to-all.mb-4(
      v-if="model.isA('membership') && model.group().parentOrSelf().hasSubgroups()"
      v-model="applyToAll"
      :label="$t('change_volume_form.membership.apply_to_organization', { organization: model.group().parentOrSelf().name })"
      hide-details)
  v-card-actions(align-center)
    help-btn(path="en/user_manual/users/email_settings#group-email-settings")
    v-spacer
    v-btn.change-volume-form__submit(
      variant="tonal"
      :disabled="!formChanged"
      :loading="saving"
      @click="submit"
      color="primary")
      span(v-t="'common.action.update'")
</template>
