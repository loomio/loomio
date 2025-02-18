<script lang="js">
import Session from '@/shared/services/session';

export default
{
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
v-card.suggestion-list(outlined :elevation=8 v-show='query' ref='suggestions' :style="positionStyles")
  template(v-if='mentions.length')
    v-list(dense)
      v-list-item(v-for='(row, index) in mentions' :key='row.id' :class="{ 'v-list-item--active': navigatedUserIndex === index }" @click='$emit("select-row", row)')
        v-list-item-title
          | {{ row.name }}
          span.text--secondary(v-if="row.handle == currentUser.username") &nbsp; ({{ $t('common.you') }})
          span.text--secondary(v-if="showUsername") &nbsp; {{ "@" + row.handle }}
  v-card-subtitle(v-if='mentions.length == 0' v-t="'common.no_results_found'")
  .d-flex.justify-center
    v-progress-linear(v-if="loading" indeterminate color='primary' size='24' width="2")
</template>
