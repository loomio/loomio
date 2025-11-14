<script setup lang="js">
import { computed } from 'vue';
import OutcomeService from '@/shared/services/outcome_service';
import EventService from '@/shared/services/event_service';
import { pick } from 'lodash-es';

const props = defineProps({
  event: Object,
  eventable: Object
});

const dockActions = computed(() => {
  return OutcomeService.actions(props.eventable, this);
});

const menuActions = computed(() => {
  return pick(EventService.actions(props.event, this), ['pin_event', 'unpin_event', 'notification_history']);
});
</script>

<template lang="pug">
section.outcome-created.strand-item__outcome-created(id="'outcome-'+ eventable.id")
  strand-item-headline(:event="event" :eventable="eventable")
  //- formatted-text.thread-item__body.new-comment__body(:model="eventable" field="body")
  //- link-previews(:model="poll")
  //- document-list(:model='eventable' skip-fetch)
  //- attachment-list(:attachments="eventable.attachments")
  //- action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions' icons)
</template>