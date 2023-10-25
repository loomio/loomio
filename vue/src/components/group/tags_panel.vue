<script lang="js">
import AppConfig from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import { debounce, some, every, compact, omit, values, keys, intersection } from 'lodash';

export default
{
  data() {
    return {
      group: null,
      pollsLoader: null,
      discussionsLoader: null
    };
  },

  created() {
    this.init();

    return this.watchRecords({
      collections: ['polls', 'groups', 'discussions'],
      query: () => this.findRecords()
    });
  },

  watch: {
    '$route.params.tag': 'init'
  },

  methods: {
    init() {
      this.group = Records.groups.find(this.$route.params.key);

      this.pollsLoader = new RecordLoader({
        collection: 'polls',
        params: {
          group_id: this.group.id,
          tags: this.$route.params.tag,
          subgroups: 'all'
        }
      });

      this.discussionsLoader = new RecordLoader({
        collection: 'discussions',
        params: {
          filter: 'all',
          tags: this.$route.params.tag,
          group_id: this.group.id,
          subgroups: 'all'
        }
      });

      this.pollsLoader.fetchRecords();
      this.discussionsLoader.fetchRecords();
      this.findRecords();
    },

    findRecords() {
      this.polls = Records.polls.collection.chain().
        find({groupId: {$in: this.group.selfAndSubgroupIds()}}).
        find({tags: {$contains: this.$route.params.tag}}).
        find({discardedAt: null}).
        simplesort('createdAt', true).data();

      this.discussions = Records.discussions.collection.chain().
        find({groupId: {$in: this.group.selfAndSubgroupIds()}}).
        find({tags: {$contains: this.$route.params.tag}}).
        find({discardedAt: null}).
        simplesort('lastActivityAt', true).data();
    }
  }
};

</script>

<template lang="pug">
.tags-panel
  v-card.my-4.pa-2(outlined)
    tags-display(:tags="group.tagNames()" :group="group" :show-counts="!!group.parentId" :show-org-counts="!group.parentId" :selected="$route.params.tag")
  loading(v-if="!group")
  div(v-if="group")
    v-card.mb-4(outlined)
      v-card-title(v-t="'common.threads'")
      div(v-if="discussionsLoader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        .discussions-panel__list.thread-preview-collection__container(
          v-if="discussions.length"
        )
          v-list.thread-previews(two-line)
            thread-preview(
              v-for="thread in discussions"
              :key="thread.id"
              :thread="thread"
              group-page
            )
          .d-flex.justify-center
            .d-flex.flex-column.align-center
              .text--secondary {{discussions.length}} / {{discussionsLoader.total}}
              v-btn.my-2.discussions-panel__show-more(
                outlined
                color='accent'
                v-if="discussions.length < discussionsLoader.total && !discussionsLoader.exhausted"
                :loading="discussionsLoader.loading"
                @click="discussionsLoader.fetchRecords()"
              )
                span(v-t="'common.action.load_more'")
        p.pa-4.text-center(
          v-if='discussions.length == 0 && !discussionsLoader.loading'
          v-t="'common.no_results_found'"
        )
      loading(v-if="discussionsLoader.loading")

    v-card(outlined)
      v-card-title(v-t="'group_page.polls'")
      div(v-if="pollsLoader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")

      div(v-if='polls.length')
        v-list(two-line avatar )
          poll-common-preview(
            :poll='poll'
            v-for='poll in polls'
            :key='poll.id'
            :display-group-name="poll.groupId != group.id"
          )
        .d-flex.justify-center
          .d-flex.flex-column.align-center
            .text--secondary
              | {{polls.length}} / {{pollsLoader.total}}
            v-btn.my-2.polls-panel__show-more(
              v-if="polls.length < pollsLoader.total && !pollsLoader.exhausted"
              @click="loader.fetchRecords({per: 50})"
              :loading="pollsLoader.loading"
              color='accent'
              outlined
            )
              span(v-t="'common.action.load_more'")
      p.pa-4.text-center(
        v-if='polls.length == 0 && !pollsLoader.loading'
        v-t="'polls_panel.no_polls'"
      )
      loading(v-if="pollsLoader.loading")

</template>
