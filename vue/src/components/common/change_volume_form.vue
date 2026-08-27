<script setup>
import { computed, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import PushSubscriptionService from '@/shared/services/push_subscription_service';

const { model, showClose = true } = defineProps({
  model: { type: Object, required: true },
  close: Function,
  showClose: { type: Boolean, default: true }
});

const router = useRouter();
const initialEmail = defaultVolumeEmail();
const initialPush = defaultVolumePush();
const volumeEmail = ref(initialEmail);
const volumePush = ref(initialPush);
const deliveryChannel = ref(defaultDeliveryChannel());
const previousEmail = ref(initialEmail === 'quiet' ? 'normal' : initialEmail);
const previousPush = ref(initialPush === 'quiet' ? 'normal' : initialPush);
const applyToAll = ref(model.isA('user'));
const saving = ref(false);

const title = computed(() => {
  switch (model.constructor.singular) {
  case 'topic':      return model.topicable().title;
  case 'membership': return model.group().name;
  case 'user':       return model.name;
  default:           return '';
  }
});

const formChanged = computed(() =>
  volumeEmail.value !== initialEmail ||
  volumePush.value !== initialPush ||
  applyToAll.value !== model.isA('user')
);

const pushSupported = computed(() => PushSubscriptionService.supported());
const pushDenied = computed(() => PushSubscriptionService.permission() === 'denied');
const requiresPush = computed(() => ['normal', 'loud'].includes(volumePush.value));

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
  case 'user':       return model.defaultMembershipVolumeEmail;
  default:           return 'normal';
  }
}

function defaultVolumePush() {
  switch (model.constructor.singular) {
  case 'topic':      return model.readerVolumePush;
  case 'membership': return model.volumePush;
  case 'user':       return model.defaultMembershipVolumePush;
  default:           return 'quiet';
  }
}

function defaultDeliveryChannel() {
  const emailActive = ['normal', 'loud'].includes(initialEmail);
  const pushActive = ['normal', 'loud'].includes(initialPush);
  if (emailActive && pushActive) return 'email_and_push';
  return pushActive ? 'push' : 'email';
}

function translateKey(key) {
  if (model.isA('user')) return 'change_volume_form.all_groups';
  const singular = model.isA('topic') ? 'discussion' : model.constructor.singular;
  return `change_volume_form.${key || singular}`;
}

async function submit() {
  saving.value = true;
  try {
    if (requiresPush.value && !(await PushSubscriptionService.enabled())) {
      await PushSubscriptionService.enable();
    }
    await model.saveVolume(volumeEmail.value, volumePush.value, applyToAll.value);
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

function openNotificationPreferences() {
  EventBus.$emit('closeModal');
  router.push('/email_preferences');
}
</script>

<template lang="pug">
v-card.change-volume-form(:title="$t(translateKey() + '.title', { title })")
  template(v-slot:append)
    dismiss-modal-button(v-if="showClose")
  v-card-text.px-2
    v-radio-group.mb-4(
      hide-details
      v-model="deliveryChannel"
      :label="$t('change_volume_form.volume_channel_label')")
      v-radio(value="email" :label="$t('change_volume_form.email_channel')")
      v-radio(value="push" :label="$t('change_volume_form.push_channel')" :disabled="!pushSupported || pushDenied")
      v-radio(value="email_and_push" :label="$t('change_volume_form.email_and_push_channel')" :disabled="!pushSupported || pushDenied")

    v-radio-group.mb-4(
      v-if="deliveryChannel !== 'push'"
      hide-details
      v-model="volumeEmail"
      :label="$t('change_volume_form.volume_email_label')")
      v-radio.volume-quiet(value="quiet" :label="$t('change_volume_form.muted_option')")
      v-radio.volume-normal(value="normal" :label="$t('change_volume_form.when_notified_option')")
      v-radio.volume-loud(value="loud" :label="$t('change_volume_form.all_activity_option')")

    v-radio-group.mb-4(
      v-if="deliveryChannel !== 'email'"
      hide-details
      v-model="volumePush"
      :label="$t('change_volume_form.volume_push_label')")
      v-radio.volume-quiet(value="quiet" :label="$t('change_volume_form.muted_option')")
      v-radio.volume-normal(value="normal" :label="$t('change_volume_form.when_notified_option')")
      v-radio.volume-loud(value="loud" :label="$t('change_volume_form.all_activity_option')")

    v-alert.mb-4(
      v-if="!pushSupported || pushDenied"
      type="info"
      variant="tonal")
      span(v-t="pushDenied ? 'push_notifications.permission_denied' : 'push_notifications.not_supported'")
      br
      a(@click="openNotificationPreferences" v-t="'push_notifications.manage_devices'")

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
