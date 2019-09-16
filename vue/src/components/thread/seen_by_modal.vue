<script lang="coffee">
import Records        from '@/shared/services/records'

export default
  props:
    close: Function
    discussion: Object
  data: ->
    historyData: []
    historyLoading: false
    historyError: false

  created: ->
    @historyLoading = true
    Records.discussions.fetchHistoryFor(@discussion).then (data) =>
      @historyLoading = false
      @historyData = data || []
    , (err) =>
      @historyLoading = false
      @historyError = true
</script>
<template lang="pug">
v-card
  v-card-title
    h1.headline(v-t="'discussion_last_seen_by.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-layout(justify-center)
    v-progress-circular(color="primary" v-if="historyLoading" indeterminate)
  v-card-text(v-if="!historyLoading")
    p(v-if="historyError && historyData.length == 0" v-t="'announcement.history_error'")
    p(v-if="!historyError && historyData.length == 0" v-t="'discussion_last_seen_by.no_one'")
    div(v-for="reader in historyData" :key="reader.id")
      h4.mt-4.mb-2
        span {{reader.user_name}}
        mid-dot
        time-ago(:date="reader.last_read_at")
</template>
