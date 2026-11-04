<script lang="js">
import { exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';
import Session from '@/shared/services/session';

export default {
  props: {
    name: String,
    zone: String
  },
  computed: {
    time() { return exact(parseISO(this.name), this.zone || Session.user().timeZone); }
  }
};
</script>

<template lang="pug">
pre.poll-meeting-time.my-0 {{time}}
</template>
