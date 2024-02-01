<script lang="js">
import { differenceInHours } from 'date-fns';
import { exact, approximate } from '@/shared/helpers/format_time';

export default {
  props: {
    poll: Object,
    approximate: Boolean
  },

  methods: {
    exact,
    timeMethod() {
      if (this.approximate) {
        return approximate(this.time);
      } else {
        return exact(this.time);
      }
    }
  },

  computed: {
    time() {
      const key = this.poll.isVotable() ? 'closingAt' : 'closedAt';
      return this.poll[key];
    },

    translationKey() {
      if (this.poll.isVotable()) {
        return 'common.closing_in';
      } else {
        return 'common.closed_ago';
      }
    },

    color() {
      if (this.poll.isVotable()) {
        if (differenceInHours(this.poll.closingAt, new Date) < 48) {
          return 'warning';
        } else {
          return '';
        }
      } else {
        return 'error';
      }
    },

    styles() {
      if (this.color) {
        return {color: 'var(--v-'+this.color+'-base)'};
      } else {
        return {};
      }
    }
  }
};

</script>

<template lang="pug">
span(:style="styles")
  abbr.closing-in.timeago--inline(v-if="poll.closingAt")
    span(v-t="{ path: translationKey, args: { time: timeMethod(time) } }" :title="exact(time)")
  span(v-else v-t="'poll_common_wip_field.past_tense'")
</template>
