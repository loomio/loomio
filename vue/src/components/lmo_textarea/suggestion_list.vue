<script lang="js">
import Session from '@/shared/services/session';

export default {
  data() {
    return {
      currentUser: Session.user()
    }
  },
  props: {
    query: String,
    loading: Boolean,
    mentions: Array,
    positionStyles: Object,
    navigatedUserIndex: Number,
    showUsername: {
      type: Boolean,
      default: false
    }
  }
};
</script>

<template lang="pug">
v-card.suggestion-list(
  :elevation=8
  v-show='query'
  ref='suggestions'
  :style="positionStyles"
)
  v-list(v-if="mentions.length" density="compact")
    v-list-item(
      v-for='(row, index) in mentions'
      :key='row.id'
      :class="{ 'v-list-item--active': navigatedUserIndex === index }"
      @click='$emit("select-row", row)'
    )
      v-list-item-title
        | {{ row.name }}
        span.text-medium-emphasis(v-if="row.handle == currentUser.username") &nbsp; ({{ $t('common.you') }})
        span.text-medium-emphasis(v-if="showUsername") &nbsp; {{ "@" + row.handle }}
  v-list(v-else density="compact")
    v-list-item
      v-progress-circular(
        v-if="loading"
        indeterminate
        color='primary'
        size='24'
        width="2"
      )
      span(v-else v-t="'common.no_results_found'")

  .d-flex.justify-center
    v-progress-linear(v-if="loading" indeterminate color='primary' size='24' width="2")
</template>
