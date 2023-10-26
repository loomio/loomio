<script lang="js">
import Records        from '@/shared/services/records';
import { orderBy } from 'lodash';
export default {
  props: {
    discussion: Object
  },
  data() {
    return {
      historyData: [],
      historyLoading: false,
      historyError: false
    };
  },
  created() {
    this.historyLoading = true;
    Records.fetch({path: `discussions/${this.discussion.id}/history`}).then(data => {
      this.historyLoading = false;
      this.historyData = orderBy(data, ['last_read_at'], ['desc']) || [];
    } , err => {
      this.historyLoading = false;
      this.historyError = true;
    });
  }
};
</script>
<template lang="pug">
v-card
  v-card-title
    h1.headline(tabindex="-1" v-t="'discussion_last_seen_by.title'")
    v-spacer
    dismiss-modal-button
  v-layout(justify-center)
    v-progress-circular(color="primary" v-if="historyLoading" indeterminate)
  v-card-text(v-if="!historyLoading")
    p(v-if="historyError && historyData.length == 0" v-t="'announcement.history_error'")
    p(v-if="!historyError && historyData.length == 0" v-t="'discussion_last_seen_by.no_one'")
    div(v-for="reader in historyData" :key="reader.id")
      strong {{reader.user_name}}
      mid-dot
      time-ago(:date="reader.last_read_at")
</template>
