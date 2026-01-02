<script lang="js">
import Records        from '@/shared/services/records';
import { orderBy } from 'lodash-es';
export default {
  props: {
    discussion: Object
  },
  data() {
    return {
      historyData: [],
      historyLoading: false,
      historyError: false,
      errorMessage: null
    };
  },
  created() {
    this.historyLoading = true;
    Records.fetch({path: `discussions/${this.discussion.id}/history`}).then(data => {
      this.historyLoading = false;
      this.historyData = orderBy(data, ['last_read_at'], ['desc']) || [];
    } , err => {
      this.errorMessage = err.message;
      this.historyLoading = false;
      this.historyError = true;
    });
  }
};
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
