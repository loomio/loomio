<script lang="js">
import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import EventBus      from '@/shared/services/event_bus';
import ThreadLoader  from '@/shared/loaders/thread_loader';
import WatchRecords  from '@/mixins/watch_records';
import StrandActionsPanel from '@/components/strand/actions_panel';

export default {
  mixins: [WatchRecords],
  components: { StrandActionsPanel },

  data() {
    return {
      poll: null,
      loader: null
    };
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

        if (poll.topic()) {
          this.loader = new ThreadLoader(poll);
          this.loader.addContextRule();
          this.loader.addLoadOldestRule();
          this.loader.fetch();

          this.watchRecords({
            key: 'poll-strand-' + poll.id,
            collections: ['events'],
            query: () => {
              this.loader.updateCollection();
            }
          });
        }
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
        v-sheet.strand-card.thread-card.mb-8.pb-4.rounded(v-if="loader" elevation=1)
          strand-list.pt-3.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection")
          strand-actions-panel(:model="poll")
</template>
