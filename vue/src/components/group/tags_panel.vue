<script setup>
import { ref, watch } from 'vue';
import { useRoute } from 'vue-router';
import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { group } = defineProps({
  group: {type: Object, required: true}
});
const route = useRoute();
const topicsLoader = ref(null);
const topics = ref([]);
const { watchRecords } = useWatchRecords();

function findRecords() {
  topics.value = Records.topics.collection.chain()
    .find({groupId: {$in: group.selfAndSubgroupIds()}})
    .find({tags: {$contains: route.params.tag}})
    .simplesort('lastActivityAt', true)
    .data();
}

function init() {
  topicsLoader.value = new RecordLoader({
    collection: 'topics',
    params: {filter: 'all', tags: route.params.tag, group_id: group.id}
  });
  topicsLoader.value.fetchRecords();
  findRecords();
}

watchRecords({
  collections: ['topics', 'groups', 'discussions', 'polls'],
  query: findRecords
});
watch(() => route.params.tag, init);
init();
</script>

<template lang="pug">
.tags-panel
  v-card.my-4.pa-2(variant="flat")
    tags-display(:tags="group.tagNames()" :group="group" :selected="$route.params.tag")
  loading(v-if="!group")
  div(v-if="group")
    v-card.mb-4(variant="flat")
      div(v-if="topicsLoader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        .discussions-panel__list.topic-preview-collection__container(
          v-if="topics.length"
        )
          v-list.topic-previews(lines="two")
            topic-preview(
              v-for="topic in topics"
              :key="topic.id"
              :topic="topic"
              group-page
            )
          .d-flex.justify-center
            .d-flex.flex-column.align-center
              .text-medium-emphasis {{topics.length}} / {{topicsLoader.total}}
              v-btn.my-2(
                variant="tonal"
                color='primary'
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
