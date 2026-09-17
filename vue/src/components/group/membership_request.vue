<script setup lang="js">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';

const { request } = defineProps({ request: Object });
const { t } = useI18n();

const isDeclining = ref(false);
const declineReason = ref('');
const submitting = ref(false);

const canSubmit = computed(() => declineReason.value.trim().length > 0);

const openDecline = () => {
  isDeclining.value = true;
  declineReason.value = '';
};

const closeDecline = () => {
  isDeclining.value = false;
};

const approveRequest = async () => {
  submitting.value = true;
  try {
    await Records.membershipRequests.approve(request);
    Flash.success('membership_requests_page.messages.request_approved_success');
  } finally {
    submitting.value = false;
  }
};

const declineRequest = async () => {
  submitting.value = true;
  try {
    await Records.membershipRequests.decline(request, declineReason.value.trim());
    Flash.success('membership_requests_page.messages.request_declined_success');
    closeDecline();
  } finally {
    submitting.value = false;
  }
};

const ignoreRequest = async () => {
  submitting.value = true;
  try {
    await Records.membershipRequests.ignore(request);
    Flash.success('membership_requests_page.messages.request_ignored_success');
    closeDecline();
  } finally {
    submitting.value = false;
  }
};
</script>

<template lang="pug">
v-list.membership-requests(lines="two" density="compact")
  v-list-item
    template(v-slot:prepend)
      user-avatar.mr-2(:user="request.actor()" :size="40")
    v-list-item-title.membership-request__name
      span {{ request.actor().name }} &lt;{{ request.requestorEmail }}&gt;
      span.text-body-small.text-medium-emphasis(v-if="request.isPending()")
        space
        mid-dot
        time-ago(:date="request.createdAt")
      span.membership-request__response.text-body-small.text-medium-emphasis(v-if="!request.isPending()")
        space
        span {{ t('membership_requests_page.previous_request_response', { response: request.formattedResponse(), responder: request.responder().name }) }}
        mid-dot
        time-ago(:date="request.responseAt()")
    v-list-item-subtitle.membership-request__introduction {{ request.introduction }}
    p.membership-request__decline-reason.mt-2(v-if="request.declineReason") {{ request.declineReason }}
    template(v-slot:append)
      v-btn.membership-requests-page__approve(v-if="request.isPending()" text icon :aria-label="t('membership_requests_page.approve')" :disabled="submitting" @click="approveRequest")
        common-icon(name="mdi-check")
      v-btn.membership-requests-page__decline(v-if="request.isPending()" text icon :aria-label="t('membership_requests_page.decline')" :disabled="submitting" @click="openDecline")
        common-icon(name="mdi-close")

v-dialog(:model-value="isDeclining" max-width="600" @update:model-value="value => { if (!value) closeDecline(); }")
  v-card(:title="t('membership_requests_page.decline_request')")
    v-card-text
      p.membership-request__decline-help.mb-4.text-medium-emphasis {{ t('membership_requests_page.decline_help') }}
      v-textarea.membership-request__decline-reason-input(
        v-model="declineReason"
        :label="t('membership_requests_page.decline_reason')"
        required
        :maxlength="500"
        autofocus
      )
    v-card-actions
      v-btn.membership-request__ignore(:disabled="submitting" @click="ignoreRequest") {{ t('membership_requests_page.ignore') }}
      v-spacer
      v-btn(@click="closeDecline") {{ t('common.action.cancel') }}
      v-btn.membership-request__response-submit(
        color="primary"
        variant="elevated"
        :disabled="!canSubmit"
        :loading="submitting"
        @click="declineRequest"
      ) {{ t('membership_requests_page.decline') }}
</template>
