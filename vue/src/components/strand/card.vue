<script lang="js">
import AbilityService           from '@/shared/services/ability_service';
import StrandActionsPanel from './actions_panel';

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
v-sheet.strand-card.thread-card.mb-8.pb-4.rounded(elevation=1)
  //- p(v-for="rule in loader.rules") {{rule.name}}
  strand-list.pt-3.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection")
  strand-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
  //- thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
</template>
