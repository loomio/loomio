<script lang="js">
import Session from '@/shared/services/session';

export default
{
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
v-card.suggestion-list(outlined :elevation=8 v-show='query' ref='suggestions' :style="positionStyles")
  template(v-if='mentionable.length')
    v-list(dense)
      v-list-item(v-for='(user, index) in mentionable' :key='user.id' :class="{ 'v-list-item--active': navigatedUserIndex === index }" @click='$emit("select-user", user)')
        v-list-item-title
          | {{ user.name }}
          span.text--secondary(v-if="user.id == currentUser.id") &nbsp; ({{ $t('common.you') }})
          span.text--secondary(v-if="showUsername") &nbsp; {{ "@" + user.username }}
  v-card-subtitle(v-if='mentionable.length == 0' v-t="'common.no_results_found'")
  .d-flex.justify-center
    v-progress-circular(v-if="loading" indeterminate color='primary' size='24' width="2")
</template>
