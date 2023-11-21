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

<template lang="pug">
.poll-common-stance
  span.caption(v-if='!stance.castAt' v-t="'poll_common_votes_panel.undecided'" )
  span(v-else)
    poll-common-stance-choices(:stance="stance")
    formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
</template>
