<script lang="js">
import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import Session       from '@/shared/services/session';
import { filter } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';

export default
{
  mixins: [WatchRecords],
  data() {
    return {
      votePolls: [],
      loader: null
    };
  },

  created() {
    this.loader = new RecordLoader({
      collection: 'polls',
      params: {
        exclude_types: 'group',
        status: 'recent'
      }
    });

    this.loader.fetchRecords();

    this.watchRecords({
      collections: ['polls', 'groups', 'memberships', 'stances'],
      query: () => this.findRecords()
    });
  },

  methods: {
    findRecords() {
      const groupIds = Session.user().groupIds();
      const pollIds = Records.stances.find({myStance: true}).map(stance => stance.pollId);

      let chain = Records.polls.collection.chain();
      chain = chain.find({discardedAt: null, closingAt: {$ne: null}, closedAt: null});
      chain = chain.find({$or: [{groupId: {$in: groupIds}}, {id: {$in: pollIds}}, {authorId: Session.user().id}]});

      const votable = p => p.iCanVote() && !p.iHaveVoted();
      this.votePolls = filter(chain.simplesort('closingAt', true).data(), votable);
    }
  }
};

</script>

<template lang="pug">
.polls-panel(v-if='votePolls.length || loader.loading')
  v-card.mb-2
    v-list(lines="two")
      template(v-if="votePolls.length")
        v-list-subheader(v-t="'dashboard_page.polls_to_vote_on'")
        poll-common-preview(
          display-group-name
          full-name
          :poll="poll",
          v-for="poll in votePolls",
          :key="poll.id"
        )
      template(v-if='!votePolls.length && loader.loading')
        v-list-subheader(v-t="'group_page.polls'")
        loading-content(:lineCount='2' v-for='(item, index) in [1]' :key='index' )
</template>
