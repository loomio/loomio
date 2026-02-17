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
  props: {
    group: Object
  },

  data() {
    return {
      polls: [],
      loader: null
    };
  },

  created() {
    this.loader = new RecordLoader({
      collection: 'polls',
      params: {
        group_key: this.group.key,
        exclude_types: 'group',
        status: 'active'
      }
    });

    this.loader.fetchRecords();

    this.watchRecords({
      collections: ['polls', 'groups', 'memberships', 'stances'],
      query: () => this.query()
    });
  },

  methods: {
    query() {
      const groupIds = Session.user().groupIds();
      const pollIds = Records.stances.find({myStance: true}).map(stance => stance.pollId);

      let chain = Records.polls.collection.chain();
      chain = chain.find({discardedAt: null, closedAt: null, groupId: this.group.id});
      this.polls = chain.simplesort('createdAt').data();
    }
  }
};

</script>

<template lang="pug">
.group-page__current-polls-panel(v-if='polls.length || loader.loading')
  v-card.mb-4.mt-4(outlined)
    v-list(two-line)
      v-subheader
        span(v-t="'dashboard_page.open_decisions'")
      poll-common-preview(v-for="poll in polls" :poll="poll" :key="poll.id")
    template(v-if='!polls.length && loader.loading')
      v-subheader(v-t="'group_page.polls'")
      loading-content(:lineCount='2' v-for='(item, index) in [1]' :key='index' )
</template>
