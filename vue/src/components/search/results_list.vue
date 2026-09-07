<script setup lang="js">
import Records from '@/shared/services/records';
import { urlForSearchResult } from '@/shared/helpers/search_result_url.mjs';

const { results, emptyText, showAuthor } = defineProps({
  results: {
    type: Array,
    required: true
  },
  emptyText: {
    type: String,
    default: null
  },
  showAuthor: {
    type: Boolean,
    default: true
  }
});

const userById = id => Records.users.find(id);
const pollById = id => Records.polls.find(id);
const groupById = id => Records.groups.find(id);
</script>

<template lang="pug">
v-list.search-results-list(lines="two")
  v-list-item(v-if="emptyText && results.length === 0")
    v-list-item-title {{ emptyText }}
  v-list-item(v-for="result in results" :key="result.id" :to="urlForSearchResult(result)")
    template(v-slot:prepend)
      poll-common-icon-panel.mr-2(v-if="['Outcome', 'Poll'].includes(result.searchable_type)" :poll="pollById(result.poll_id)" show-my-stance)
      user-avatar.mr-2(v-else :user="userById(result.author_id)")
    v-list-item-title.d-flex
      span.text-truncate {{ result.poll_title || result.discussion_title }}
      tags-display.ml-1(:tags="result.tags" size="x-small" :group="groupById(result.group_id)")
      v-spacer
      time-ago.text-medium-emphasis.search-results-list__time(:date="result.authored_at")
    v-list-item-subtitle.text--primary(v-if="result.highlight" v-html="result.highlight")
    v-list-item-subtitle
      span {{ result.searchable_type }}
      template(v-if="showAuthor")
        mid-dot
        span {{ result.author_name }}
      mid-dot
      span {{ result.group_name || $t('discussion.direct') }}
</template>

<style>
.search-results-list__time {
  font-size: 0.875rem;
}
</style>
