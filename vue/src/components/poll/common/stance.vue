<script lang="js">
import Session from '@/shared/services/session';

export default {
  components: {
    PollCommonDirective() { return import('@/components/poll/common/directive'); }
  },

  props: {
    stance: Object
  },

  computed: {
    canEdit() {
      return this.stance.latest && (this.stance.participant() === Session.user());
    }
  }
};

</script>

<template>

<div class="poll-common-stance"><span class="caption" v-if="!stance.castAt" v-t="'poll_common_votes_panel.undecided'"></span><span v-else>
    <poll-common-stance-choices :stance="stance"></poll-common-stance-choices>
    <formatted-text class="poll-common-stance-created__reason" :model="stance" column="reason"></formatted-text></span></div>
</template>
