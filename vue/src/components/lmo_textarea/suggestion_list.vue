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
    mentionable: Array,
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
  outlined
  :elevation=8
  v-show='query'
  ref='suggestions'
  :style="positionStyles")
  v-list(v-if="mentionable.length" density="compact")
    v-list-item(
      v-for='(user, index) in mentionable'
      :key='user.id'
      :class="{ 'v-list-item--active': navigatedUserIndex === index }"
      @click='$emit("select-user", user)'
    )
      v-list-item-title
        | {{ user.name }}
        span.text-medium-emphasis(v-if="user.id == currentUser.id") &nbsp; ({{ $t('common.you') }})
        span.text-medium-emphasis(v-if="showUsername") &nbsp; {{ "@" + user.username }}
  v-list(v-else density="compact")
    v-list-item
      v-progress-circular(
        v-if="loading"
        indeterminate
        color='primary'
        size='24'
        width="2")
      span(v-else v-t="'common.no_results_found'")
  .d-flex.justify-center
</template>
