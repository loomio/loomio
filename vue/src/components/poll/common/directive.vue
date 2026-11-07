<script lang="js">
import PollCommonVoteForm from '@/components/poll/common/vote_form.vue';
import { defineAsyncComponent } from 'vue';

export default {
  components: {
    'poll-common-vote-form': PollCommonVoteForm,
    'poll-dot_vote-vote-form': defineAsyncComponent(() => import('@/components/poll/dot_vote/vote_form.vue')),
    'poll-score-vote-form': defineAsyncComponent(() => import('@/components/poll/score/vote_form.vue')),
    'poll-ranked_choice-vote-form': defineAsyncComponent(() => import('@/components/poll/ranked_choice/vote_form.vue')),
    'poll-meeting-vote-form': defineAsyncComponent(() => import('@/components/poll/meeting/vote_form.vue')),
    'poll-stv-vote-form': defineAsyncComponent(() => import('@/components/poll/stv/vote_form.vue'))
  },

  props: {
    poll: Object,
    stance: Object,
    outcome: Object,
    stanceChoice: Object,
    back: Object,
    name: String,
    size: Number,
  },

  computed: {
    componentName() {
      const {
        pollType
      } = (this.stance || this.outcome || this.stanceChoice || this.poll).poll();

      if ((this.name === 'vote-form') && ['proposal', 'count', 'poll'].includes(pollType)) {
        return "poll-common-vote-form";
      } else {
        if (this.$options.components[`poll-${pollType}-${this.name}`]) {
          return `poll-${pollType}-${this.name}`;
        } else {
          return `poll-common-${this.name}`;
        }
      }
    }
  }
}
</script>

<template>
<component :is="componentName" :poll='poll' :stance='stance' :stance-choice='stanceChoice' :outcome='outcome' :back='back' :size="size"></component>
</template>
