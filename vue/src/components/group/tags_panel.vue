<script lang="js">
import AppConfig from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import WatchRecords from '@/mixins/watch_records';

export default
{
  mixins: [WatchRecords],
  data() {
    return {
      group: null,
      topicsLoader: null,
      topics: []
    };
  },

  created() {
    this.init();

    return this.watchRecords({
      collections: ['topics', 'groups', 'discussions', 'polls'],
      query: () => this.findRecords()
    });
  },

  watch: {
    '$route.params.tag': 'init'
  },

  methods: {
    init() {
      this.group = Records.groups.find(this.$route.params.key);

      this.topicsLoader = new RecordLoader({
        collection: 'topics',
        params: {
          filter: 'all',
          tags: this.$route.params.tag,
          group_id: this.group.id
        }
      });

      this.topicsLoader.fetchRecords();
      this.findRecords();
    },

    findRecords() {
      this.topics = Records.topics.collection.chain().
        find({groupId: {$in: this.group.selfAndSubgroupIds()}}).
        find({tags: {$contains: this.$route.params.tag}}).
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
      div(v-if="topicsLoader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        .discussions-panel__list.thread-preview-collection__container(
          v-if="topics.length"
        )
          v-list.thread-previews(lines="two")
            thread-preview(
              v-for="topic in topics"
              :key="topic.id"
              :topic="topic"
              group-page
            )
          .d-flex.justify-center
            .d-flex.flex-column.align-center
              .text-medium-emphasis {{topics.length}} / {{topicsLoader.total}}
              v-btn.my-2(
                outlined
                color='accent'
                v-if="topics.length < topicsLoader.total && !topicsLoader.exhausted"
                :loading="topicsLoader.loading"
                @click="topicsLoader.fetchRecords()"
              )
                span(v-t="'common.action.load_more'")
        p.pa-4.text-center(
          v-if='topics.length == 0 && !topicsLoader.loading'
          v-t="'common.no_results_found'"
        )
      loading(v-if="topicsLoader.loading")

</template>
