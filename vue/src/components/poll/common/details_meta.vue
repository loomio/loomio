<script setup lang="js">
import { exact } from '@/shared/helpers/format_time';
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

const { poll } = defineProps({
  poll: Object
});

const openedOrOpeningAt = computed(() => poll.openedAt || poll.openingAt);
const openedOrOpeningAtLabel = computed(() => {
  return poll.openedAt ? 'poll_common_details_meta.opened' : 'poll_common_details_meta.opens';
});
const closedOrClosingAt = computed(() => poll.closedAt || poll.closingAt);
const closedOrClosingAtLabel = computed(() => {
  return poll.closedAt ? 'poll_common_details_meta.closed' : 'poll_common_details_meta.closes';
});
</script>

<template lang="pug">
.poll-common-details-panel__started-by.d-flex.flex-wrap.align-center.ga-1.text-medium-emphasis.text-body-medium.mb-4
  div
    span {{ t('poll_card.poll_type_by_name', { name: poll.authorName(), poll_type: poll.translatedPollTypeCaps() }) }}
    template(v-if="openedOrOpeningAt")
      mid-dot
      span {{ t(openedOrOpeningAtLabel) }}
      space
      time-ago(:date="openedOrOpeningAt")
    template(v-if="closedOrClosingAt")
      mid-dot
      span {{ t(closedOrClosingAtLabel) }}
      space
      time-ago(v-if="poll.closedAt" :date="closedOrClosingAt")
      abbr(v-else :title="exact(closedOrClosingAt)") {{ exact(closedOrClosingAt) }}
  slot
</template>
