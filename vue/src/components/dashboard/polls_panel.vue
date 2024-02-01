<script lang="js">
import AppConfig from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import EventBus       from '@/shared/services/event_bus';
import Session       from '@/shared/services/session';
import { escapeRegExp, reject, filter } from 'lodash-es';
import { subDays } from 'date-fns';

export default
{
  data() {
    return {
      votePolls: [],
      otherPolls: [],
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
      chain = chain.find({discardedAt: null, closingAt: {$ne: null}});
      chain = chain.find({$or: [{groupId: {$in: groupIds}}, {id: {$in: pollIds}}, {authorId: Session.user().id}]});
      chain = chain.find({$or: [{closedAt: null}, {closedAt: {$gt: subDays(new Date, 3)}}]});

      if (this.$route.query.q) {
        const rx = new RegExp(escapeRegExp(this.$route.query.q), 'i');
        chain = chain.find({$or: [{'title': {'$regex': rx}},
                                 {'description': {'$regex': rx}}]});
      }

      const votable = p => p.iCanVote() && !p.iHaveVoted();
      this.votePolls = filter(chain.simplesort('closingAt', true).data(), votable);
      this.otherPolls = reject(chain.simplesort('closingAt', true).data(), votable);
    }
  }
};


</script>

<template lang="pug">
.polls-panel(v-if='otherPolls.length || votePolls.length || loader.loading')
  v-card.mb-2
    v-list(two-line avatar)
      template
        v-subheader(v-t="'dashboard_page.polls_to_vote_on'")
        poll-common-preview(
          v-if="votePolls.length",
          :poll="poll",
          v-for="poll in votePolls",
          :key="poll.id"
        )
        v-card-text(
          v-if="votePolls.length == 0",
          v-t="'dashboard_page.no_polls_to_vote_on'"
        )
      template(v-if="otherPolls.length")
        v-subheader(v-t="'dashboard_page.recent_polls'")
        poll-common-preview(:poll='poll' v-for='poll in otherPolls' :key='poll.id')
      template(v-if='!votePolls.length && !otherPolls.length && loader.loading')
        v-subheader(v-t="'group_page.polls'")
        loading-content(:lineCount='2' v-for='(item, index) in [1]' :key='index' )
</template>
