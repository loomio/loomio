<script lang="js">
import OutcomeService from '@/shared/services/outcome_service';
import EventService from '@/shared/services/event_service';

import { pick } from 'lodash';

export default {
  props: {
    event: Object,
    eventable: Object
  },

  computed: {
    dockActions() {
      return OutcomeService.actions(this.eventable, this);
    },
    menuActions() {
      return pick(EventService.actions(this.event, this), ['pin_event', 'unpin_event', 'notification_history']);
    }
  }
};

</script>

<template lang="pug">
section.outcome-created.strand-item__outcome-created(id="'outcome-'+ eventable.id")
  strand-item-headline(:event="event" :eventable="eventable")
  //- formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  //- link-previews(:model="poll")
  //- document-list(:model='eventable' skip-fetch)
  //- attachment-list(:attachments="eventable.attachments")
  //- action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions' icons)
</template>
