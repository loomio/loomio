<script setup>
import { ref } from 'vue';
import Records from '@/shared/services/records';
import { orderBy } from 'lodash-es';

function userFor(reader) { return Records.users.find(reader.user_id); }

const { topic } = defineProps({ topic: Object });

const seenByData = ref([]);
const seenByLoading = ref(true);
const seenByError = ref(false);

Records.fetch({path: `topics/${topic.id}/history`}).then(data => {
  seenByData.value = orderBy(data, ['last_read_at'], ['desc']) || [];
  Records.users.fetchAnyMissingById(seenByData.value.map(r => r.user_id));
}).catch(() => {
  seenByError.value = true;
}).finally(() => {
  seenByLoading.value = false;
});
</script>

<template lang="pug">
v-card(:title="$t('discussion_last_seen_by.title')")
  template(v-slot:append)
    dismiss-modal-button
  .d-flex.justify-center.pa-8(v-if="seenByLoading")
    v-progress-circular(color="primary" indeterminate)
  v-card-text.text-body-2(v-else)
    p(v-if="seenByError" v-t="'announcement.history_error'")
    p(v-else-if="seenByData.length == 0" v-t="'discussion_last_seen_by.no_one'")
    div.d-flex.align-center.ga-2.py-1(v-else v-for="reader in seenByData" :key="reader.reader_id")
      user-avatar(v-if="userFor(reader)" :user="userFor(reader)" :size="28" no-link)
      span {{reader.user_name}}
      mid-dot
      time-ago.text-medium-emphasis(:date="reader.last_read_at")
</template>
