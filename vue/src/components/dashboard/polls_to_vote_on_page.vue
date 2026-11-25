<script setup lang="js">
import { onMounted } from 'vue';
import EventBus from '@/shared/services/event_bus';
import GroupPollsPanel from '@/components/group/polls_panel.vue';

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

onMounted(() => {
  EventBus.$emit('content-title-visible', false);
  EventBus.$emit('currentComponent', {
    titleKey: 'dashboard_page.polls_to_vote_on',
    page: 'pollsToVoteOnPage',
    group: null
  });
});
</script>

<template lang="pug">
v-main
  v-container.polls-to-vote-on-page.max-width-1024.px-2.px-sm-4
    h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'dashboard_page.dashboard'")
    dashboard-cards
    group-polls-panel(dashboard default-status="vote")
</template>
