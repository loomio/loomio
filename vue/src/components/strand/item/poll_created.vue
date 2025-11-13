<script setup lang="js">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import PollService from '@/shared/services/poll_service';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import EventBus from '@/shared/services/event_bus';
import EventService from '@/shared/services/event_service';
import { pickBy, assign, omit } from 'lodash-es';
import { useWatchRecords } from '@/shared/composables/use_watch_records';
import { useUrlFor } from '@/shared/composables/use_url_for';

const props = defineProps({
  event: Object,
  collapsed: Boolean,
  eventable: Object
});

const buttonPressed = ref(false);
const myStance = ref(null);
const dockActions = ref([]);
const menuActions = ref([]);
const editStanceAction = ref(null);
const { watchRecords } = useWatchRecords();
const { urlFor } = useUrlFor();

const poll = computed(() => props.eventable);

const rebuildActions = () => {
  let pollActions = PollService.actions(poll.value, this, props.event);
  editStanceAction.value = pollActions["edit_stance"];
  if (poll.value.pollType != 'meeting') {
    pollActions = omit(pollActions, "edit_stance");
  }
  const eventActions = EventService.actions(props.event, this);
  myStance.value = poll.value.myStance();
  menuActions.value = assign(pickBy(pollActions, v => v.menu), pickBy(eventActions, v => v.menu));
  dockActions.value = pickBy(pollActions, v => v.dock);
};

const viewed = (seen) => {
  if (seen &&
      Session.isSignedIn() &&
      Session.user().autoTranslate &&
      dockActions.value['translate_poll'] &&
      dockActions.value['translate_poll'].canPerform()) {
    dockActions.value['translate_poll'].perform().then(() => rebuildActions());
  }
};

const handleStanceSaved = () => {
  EventBus.$emit('refreshStance');
};

onMounted(() => {
  EventBus.$on('stanceSaved', handleStanceSaved);
  
  watchRecords({
    collections: ["stances", "polls"],
    query: () => {
      rebuildActions();
    }
  });
});

onBeforeUnmount(() => {
  EventBus.$off('stanceSaved', handleStanceSaved);
});
</script>

<template lang="pug">
section.strand-item.poll-created(v-intersect.once="{handler: viewed}")
  .d-flex.justify-space-between
    .poll-common-card__title.text-h6.pb-1(tabindex="-1")
      router-link.underline-on-hover.text-high-emphasis(:to="urlFor(poll)" )
        plain-text(:model="poll" field="title")
  div(v-if="!collapsed")
    poll-common-set-outcome-panel(:poll='poll' v-if="!poll.outcome()")
    poll-common-outcome-panel(:outcome='poll.outcome()' v-if='poll.outcome()')
    .poll-common-details-panel__started-by.text-medium-emphasis.text-body-2.mb-4
      span(v-t="{ path: 'poll_card.poll_type_by_name', args: { name: poll.authorName(), poll_type: poll.translatedPollTypeCaps() } }")
      mid-dot
      poll-common-closing-at.ml-1(:poll='poll')
      tags-display.ml-2(:tags="poll.tags" :group="poll.group()" smaller)
    formatted-text.poll-common-details-panel__details(:model="poll" field="details")
    link-previews(:model="poll")
    attachment-list(:attachments="poll.attachments")
    document-list(:model='poll')
    poll-common-chart-panel(:poll='poll')
    poll-common-action-panel(:poll='poll' :editStanceAction :key="poll.id")
    action-dock.my-2(:actions="dockActions" :menu-actions="menuActions" variant="tonal" color="primary")
</template>