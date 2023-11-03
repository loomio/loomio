<script lang="js">
import Vue from 'vue';
import AppConfig                from '@/services/app_config';
import EventBus                 from '@/services/event_bus';
import RecordLoader             from '@/services/record_loader';
import AbilityService           from '@/services/ability_service';
import Session from '@/services/session';
import Records from '@/services/records';
import Flash   from '@/services/flash';
import ThreadService  from '@/services/thread_service';
import StrandActionsPanel from './actions_panel';

const excludeTypes = 'group discussion author';

export default {
  components: {
    StrandActionsPanel
  },

  props: {
    loader: Object
  },

  computed: {
    discussion() { return this.loader.discussion; },

    canStartPoll() {
      return AbilityService.canStartPoll(this.discussion);
    },

    canEditThread() {
      return AbilityService.canEditThread(this.discussion);
    }
  }
};

</script>

<template lang="pug">
v-sheet.strand-card.thread-card.mb-8
  //- p(v-for="rule in loader.rules") {{rule.name}}
  strand-list.pt-3.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection")
  strand-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
  //- thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
</template>
