<script lang="js">
import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import EventBus      from '@/shared/services/event_bus';
import LmoUrlService from '@/shared/services/lmo_url_service';

export default {
  data() {
    return {poll: null};
  },

  created() { this.init(); },

  watch: {
    '$route.params.key': 'init'
  },

  methods: {
    init() {
      Records.polls.findOrFetchById(this.$route.params.key).then(poll => {
        this.poll = poll;
        if (this.poll.group().newHost) { window.location.host = this.poll.group().newHost; }

        EventBus.$emit('currentComponent', {
          group: poll.group(),
          poll,
          title: poll.title,
          page: 'pollPage'
        });
      }).catch(function(error) {
        EventBus.$emit('pageError', error);
        if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
      });
    }
  }
};

</script>

<template lang="pug">
.poll-page
  v-main
    v-container.max-width-800.pa-sm-3.pa-0
      loading(:until="poll")
        poll-common-card(:poll='poll' is-page)
</template>
