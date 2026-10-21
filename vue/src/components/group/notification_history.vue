<script setup>
import { onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';

const { membership } = defineProps({membership: {type: Object, required: true}});
const { t } = useI18n();
const history = ref([]);
const loading = ref(false);
const failed = ref(false);
const hasMore = ref(false);
const limit = 20;

async function load() {
  loading.value = true;
  failed.value = false;
  try {
    const data = await Records.memberships.remote.getMember(membership.id, 'notification_history', {
      limit, offset: history.value.length
    });
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
v-card.membership-notification-history(:title="t('announcement.notification_history')" :subtitle="membership.user().nameOrUsername()" :loading="loading")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    p.text-medium-emphasis {{ t('membership_notification_history.explanation') }}
    p(v-if="failed" role="alert") {{ t('membership_notification_history.could_not_load_history') }}
    p(v-else-if="!loading && !history.length") {{ t('membership_notification_history.no_invitations_recorded') }}
    article.py-3(v-for="entry in history" :key="entry.id")
      h3.text-body-large
        time-ago(:date="entry.created_at")
        |  · {{ t('membership_notification_history.' + entry.kind) }}
      p(v-if="entry.sender_name") {{ entry.sender_name }}
      p(v-if="entry.email_subject") {{ entry.email_subject }}
      p.membership-notification-history__message(v-if="entry.message") {{ entry.message }}
      p(v-else) {{ t('membership_notification_history.no_custom_message') }}
      p(v-if="!entry.email_events.length")
        | {{ t('membership_notification_history.' + entry.email_status) }}
        template(v-if="entry.email_sent_at")
          |  ·
          time-ago(:date="entry.email_sent_at")
      ul(v-if="entry.email_events.length")
        li(v-for="event in entry.email_events" :key="event.id")
          | {{ t('membership_notification_history.' + event.kind) }} ·
          time-ago(:date="event.occurred_at")
          p(v-if="event.detail") {{ event.detail }}
    v-btn(v-if="hasMore || failed" :disabled="loading" @click="load") {{ t(failed ? 'common.action.retry' : 'common.action.show_more') }}
</template>

<style scoped>
.membership-notification-history__message {
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
</style>
