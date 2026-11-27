<script setup lang="js">
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import LmoUrlService from '@/shared/services/lmo_url_service';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import SubscriptionService from '@/shared/services/subscription_service';
import Flash from '@/shared/services/flash';

const { group } = defineProps({
  group: Object
});

const { t } = useI18n();

const confirmReset = ref(false);
const resetting = ref(false);
const includeIntroMessage = ref(false);

onMounted(() => {
  group.fetchToken();
});

const invitationLink = computed(() => (
  group.token ? LmoUrlService.shareableLink(group) : t('common.action.loading')
));

const isTrial = computed(() => group.parentOrSelf().subscription?.plan === 'trial');

const invitationMessage = computed(() => {
  const key = isTrial.value
    ? 'invitation_form.trial_shareable_invitation_message'
    : 'invitation_form.shareable_invitation_message';
  return t(key, {
    groupName: group.name,
    site_name: AppConfig.theme?.site_name || 'Loomio',
    link: invitationLink.value
  });
});

const showTrialNote = computed(() => (
  !Session.user().emailInvitationsAllowed() && !group.emailInvitationsAllowed()
));

const upgradeUrl = computed(() => SubscriptionService.upgradeUrl(group.parentOrSelf()));
const maxMembers = computed(() => group.parentOrSelf().subscription?.max_members);
const membersUsed = computed(() => group.parentOrSelf().orgMembersCount || 0);

function copyText(text) {
  navigator.clipboard.writeText(text).then(
    () => Flash.success('common.copied'),
    () => Flash.error('invitation_form.error')
  );
}

function resetInvitationLink() {
  resetting.value = true;
  group.resetToken().then(() => {
    confirmReset.value = false;
    Flash.success('invitation_form.shareable_link_reset');
  }).finally(() => {
    resetting.value = false;
  });
}
</script>

<template lang="pug">
v-card.shareable-link-modal(:title="t('invitation_form.shareable_link_to_join_group')")
  template(v-slot:append)
    help-btn.text-medium-emphasis.mr-2(path="en/user_manual/groups/inviting_people#share-a-link-to-your-group" variant="text")
    dismiss-modal-button
  v-card-text
    v-alert.mb-4(color="info" variant="tonal")
      span(v-if="showTrialNote" v-html="t('invitation_form.trial_shareable_link_note', { upgradeUrl })")
      span(v-else) {{ t('invitation_form.shareable_invitation_explanation') }}
    v-textarea.shareable-link-modal__message(
      v-if="includeIntroMessage"
      :model-value="invitationMessage"
      :label="t('invitation_form.shareable_invitation_message_label')"
      readonly
      auto-grow
      hide-details
      rows="3"
      variant="outlined"
      color="info"
    )
      template(v-slot:append-inner)
        v-btn.shareable-link-modal__copy(variant="tonal" color="primary" size="small" @click="copyText(invitationMessage)")
          common-icon.mr-1(name="mdi-content-copy" size="small")
          span {{ t('common.copy') }}

    v-text-field.shareable-link-modal__shareable-link(
      v-else
      :model-value="invitationLink"
      :label="t('invitation_form.invite_link')"
      readonly
      hide-details
      variant="outlined"
      color="info"
    )
      template(v-slot:append-inner)
        v-btn.shareable-link-modal__copy(variant="tonal" color="primary" size="small" @click="copyText(invitationLink)")
          common-icon.mr-1(name="mdi-content-copy" size="small")
          span {{ t('common.copy') }}

    v-checkbox.shareable-link-modal__include-message.mt-2(
      v-model="includeIntroMessage"
      :label="t('invitation_form.include_intro_message')"
      density="compact"
      hide-details
    )

  v-card-actions
    v-btn.shareable-link-modal__reset(:title="t('common.reset')" @click="confirmReset = true" color="error")
      common-icon.mr-2(name="mdi-lock-reset")
      span {{ t('invitation_form.reset_the_link') }}
    v-spacer
    span.shareable-link-modal__members.text-body-small.text-medium-emphasis.mr-2(v-if="maxMembers")
      | {{ t('invitation_form.members_used', { used: membersUsed, max: maxMembers }) }}

  v-dialog(v-model="confirmReset" max-width="480")
    v-card.shareable-link-modal__reset-confirm(:title="t('invitation_form.reset_the_link')")
      v-card-text
        p {{ t('invitation_form.to_stop_people_reset_the_link') }}
      v-card-actions
        v-spacer
        v-btn.shareable-link-modal__reset-cancel(variant="text" @click="confirmReset = false") {{ t('common.action.cancel') }}
        v-btn.shareable-link-modal__reset-submit(color="error" variant="elevated" :loading="resetting" @click="resetInvitationLink()") {{ t('invitation_form.reset_the_link') }}
</template>
