<script setup lang="js">
import { ref, onMounted } from 'vue';
import Records from '@/shared/services/records';
import { orderBy } from 'lodash-es';

const props = defineProps({
  discussion: Object
});

const historyData = ref([]);
const historyLoading = ref(false);
const historyError = ref(false);
const errorMessage = ref(null);

onMounted(() => {
  historyLoading.value = true;
  Records.fetch({ path: `discussions/${props.discussion.id}/history` }).then(data => {
    historyLoading.value = false;
    historyData.value = orderBy(data, ['last_read_at'], ['desc']) || [];
  }, err => {
    errorMessage.value = err.message;
    historyLoading.value = false;
    historyError.value = true;
  });
});
</script>

<template lang="pug">
v-card(:title="$t('discussion_last_seen_by.title')")
  template(v-slot:append)
    dismiss-modal-button
  .d-flex.justify-center.pa-8(v-if="historyLoading")
    v-progress-circular(color="primary"  indeterminate)
  v-card-text.text-body-2(v-else)
    template(v-if="historyError")
      p(v-if="errorMessage") {{errorMessage}}
      p(v-else v-t="'announcement.history_error'")
    template(v-else)
      p(v-if="historyData.length == 0" v-t="'discussion_last_seen_by.no_one'")
      div(v-for="reader in historyData" :key="reader.id")
        | {{reader.user_name}}
        mid-dot
        time-ago.text-medium-emphasis(:date="reader.last_read_at")
</template>