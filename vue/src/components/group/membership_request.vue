<script setup lang="js">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';

const { request } = defineProps({ request: Object });
const { t } = useI18n();

const action = ref(null);
const responseComment = ref('');
const submitting = ref(false);

const isDeclining = computed(() => action.value === 'decline');
const canSubmit = computed(() => !isDeclining.value || responseComment.value.trim().length > 0);

const openResponse = (nextAction) => {
  action.value = nextAction;
  responseComment.value = '';
};

const closeResponse = () => {
  action.value = null;
};

const submitResponse = async () => {
  submitting.value = true;
  try {
    if (isDeclining.value) {
      await Records.membershipRequests.decline(request, responseComment.value.trim());
      Flash.success('membership_requests_page.messages.request_declined_success');
    } else {
      await Records.membershipRequests.approve(request, responseComment.value.trim());
      Flash.success('membership_requests_page.messages.request_approved_success');
    }
    closeResponse();
  } finally {
    submitting.value = false;
  }
};

const ignoreRequest = async () => {
  submitting.value = true;
  try {
    await Records.membershipRequests.ignore(request);
    Flash.success('membership_requests_page.messages.request_ignored_success');
    closeResponse();
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
      span.text-body-small.text-medium-emphasis(v-if="!request.respondedAt")
        space
        mid-dot
        time-ago(:date="request.createdAt")
      span.membership-request__response.text-body-small.text-medium-emphasis(v-if="request.respondedAt")
        space
        span {{ t('membership_requests_page.previous_request_response', { response: request.formattedResponse(), responder: request.responder().name }) }}
        mid-dot
        time-ago(:date="request.respondedAt")
    v-list-item-subtitle.membership-request__introduction {{ request.introduction }}
    p.membership-request__response-comment.mt-2(v-if="request.responseComment") {{ request.responseComment }}
    template(v-slot:append)
      v-btn.membership-requests-page__approve(v-if="!request.respondedAt" text icon :aria-label="t('membership_requests_page.approve')" @click="openResponse('approve')")
        common-icon(name="mdi-check")
      v-btn.membership-requests-page__decline(v-if="!request.respondedAt" text icon :aria-label="t('membership_requests_page.decline')" @click="openResponse('decline')")
        common-icon(name="mdi-close")

v-dialog(:model-value="Boolean(action)" max-width="600" @update:model-value="value => { if (!value) closeResponse(); }")
  v-card(:title="t(isDeclining ? 'membership_requests_page.decline_request' : 'membership_requests_page.approve_request')")
    v-card-text
      p.membership-request__decline-help.mb-4.text-medium-emphasis(v-if="isDeclining") {{ t('membership_requests_page.decline_help') }}
      v-textarea.membership-request__response-comment-input(
        v-model="responseComment"
        :label="t(isDeclining ? 'membership_requests_page.decline_reason' : 'membership_requests_page.response_comment')"
        :required="isDeclining"
        :maxlength="500"
        autofocus
      )
    v-card-actions
      v-btn.membership-request__ignore(v-if="isDeclining" :disabled="submitting" @click="ignoreRequest") {{ t('membership_requests_page.ignore') }}
      v-spacer
      v-btn(@click="closeResponse") {{ t('common.action.cancel') }}
      v-btn.membership-request__response-submit(
        color="primary"
        variant="elevated"
        :disabled="!canSubmit"
        :loading="submitting"
        @click="submitResponse"
      ) {{ t(isDeclining ? 'membership_requests_page.decline' : 'membership_requests_page.approve') }}
</template>
