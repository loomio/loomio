<script setup>
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';

const { membership } = defineProps({membership: {type: Object, required: true}});
const { t } = useI18n();
const recipientSubtitle = computed(() => {
  const name = membership.user().nameOrUsername();
  return name ? `${name} <${membership.userEmail}>` : membership.userEmail;
});
const history = ref([]);
const emailDeliveryBlocked = ref(false);
const loading = ref(false);
const failed = ref(false);
const hasMore = ref(false);
const limit = 20;

// SMTP acceptance is a completed send; later feedback supersedes that result.
// Pending, delayed and historical sends with no evidence stay neutral.
const deliveryResults = {
  sent: 'delivered', delivered: 'delivered',
  rejected: 'failed', bounced: 'failed', complained: 'failed', skipped: 'failed'
};
const entries = computed(() => history.value.map(entry => ({
  ...entry, result: deliveryResults[entry.email_status], event: entry.email_events.at(-1)
})));

async function load() {
  loading.value = true;
  failed.value = false;
  try {
    const data = await Records.memberships.remote.getMember(membership.id, 'notification_history', {
      limit, offset: history.value.length
    });
    emailDeliveryBlocked.value = data.email_delivery_blocked;
    history.value.push(...data.history);
    hasMore.value = data.history.length === limit;
  } catch {
    failed.value = true;
  } finally {
    loading.value = false;
  }
}

onMounted(load);
</script>

<template lang="pug">
v-card.membership-notification-history(:title="t('membership_notification_history.invitation_delivery_history')" :subtitle="recipientSubtitle" :loading="loading")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.px-0
    v-alert.membership-notification-history__blocked.mx-6.mb-4(v-if="emailDeliveryBlocked" type="warning" variant="tonal") {{ t('membership_notification_history.email_delivery_blocked') }}
    p.px-6(v-if="failed" role="alert") {{ t('membership_notification_history.could_not_load_history') }}
    p.px-6(v-else-if="!loading && !history.length") {{ t('membership_notification_history.no_invitations_recorded') }}
    v-expansion-panels(variant="accordion" flat)
      v-expansion-panel.membership-notification-history__item(v-for="entry in entries" :key="entry.id" :value="entry.id" :data-email-status="entry.email_status")
        v-expansion-panel-title
          .d-flex.align-center.flex-wrap.ga-3.flex-grow-1.mr-3
            .membership-notification-history__heading
              .font-weight-medium {{ t('membership_notification_history.' + entry.kind) }}
              .text-body-small.text-medium-emphasis
                template(v-if="entry.sender_name")
                  span {{ entry.sender_name }}
                  span.mx-1(aria-hidden="true") ·
                time-ago(:date="entry.created_at")
            v-chip.membership-notification-history__result(:data-result="entry.result" size="small" :color="entry.result === 'delivered' ? 'success' : entry.result === 'failed' ? 'error' : undefined")
              common-icon.mr-1(v-if="entry.result" :name="entry.result === 'delivered' ? 'mdi-check' : 'mdi-close'" size="small" aria-hidden="true")
              span {{ t('membership_notification_history.' + (entry.result ? 'delivery_result.' + entry.result : entry.email_status)) }}
        v-expansion-panel-text
          .membership-notification-history__details
            p.membership-notification-history__status
              span {{ t('membership_notification_history.' + entry.email_status) }}
              template(v-if="entry.event || entry.email_sent_at")
                span.mx-1(aria-hidden="true") ·
                time-ago(:date="entry.event ? entry.event.occurred_at : entry.email_sent_at")
            p.membership-notification-history__diagnostic(v-if="entry.event && entry.event.detail") {{ entry.event.detail }}
            .mt-4
              p.font-weight-medium.mb-1(v-if="entry.email_subject") {{ entry.email_subject }}
              pre.membership-notification-history__message.pa-3.rounded(v-if="entry.message")
                code {{ entry.message }}
              p.text-medium-emphasis(v-else) {{ t('membership_notification_history.no_custom_message') }}
    v-btn.membership-notification-history__more.mx-6(v-if="hasMore || failed" :disabled="loading" @click="load") {{ t(failed ? 'common.action.retry' : 'common.action.show_more') }}
</template>

<style scoped>
.membership-notification-history__heading {
  flex: 1 1 180px;
}

.membership-notification-history__heading,
.membership-notification-history__details {
  min-width: 0;
  overflow-wrap: anywhere;
}

.membership-notification-history__message {
  background-color: rgba(var(--v-theme-on-surface), 0.06);
  white-space: pre-wrap;
}
</style>
