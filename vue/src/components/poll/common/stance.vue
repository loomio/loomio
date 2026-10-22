<script lang="js">
import Session from '@/shared/services/session';
import { useI18n } from 'vue-i18n';

export default {
  setup() { return { t: useI18n().t }; },
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
  span.text-body-small(v-if='!stance.castAt') {{ t('poll_common_votes_panel.not_voted') }}
  span(v-else)
    poll-common-stance-choices(:stance="stance")
    formatted-text.poll-common-stance-created__reason(:model="stance" field="reason")
</template>
