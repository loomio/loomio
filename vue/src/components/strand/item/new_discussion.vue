<script setup lang="js">
import DiscussionService  from '@/shared/services/discussion_service';
import { pickBy } from 'lodash-es';
import Session from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { computed, onMounted, ref } from 'vue';

const props = defineProps({
  event: Object,
  eventable: Object,
  collapsed: Boolean
});

const actions = ref([]);

const discussion = computed(() => props.eventable);
const topic = computed(() => props.eventable.topic());
const author = computed(() => discussion.value.author());
const authorName = computed(() => discussion.value.authorName());
const dockActions = computed(() => pickBy(actions.value, v => v.dock));
const menuActions = computed(() => pickBy(actions.value, v => v.menu));

function urlFor(model, action, params) {
  return LmoUrlService.route({model, action, params});
}

function rebuildActions() {
  actions.value = DiscussionService.actions(props.eventable);
}

function viewed(viewed) {
  if (viewed && Session.isSignedIn()) {
    topic.value.markAsSeen();
    if (Session.user().autoTranslate && actions.value['translate_thread'].canPerform()) {
      actions.value['translate_thread'].perform().then(() => { rebuildActions(); });
    }
  }
}

onMounted(() => {
  rebuildActions();
});

</script>

<template lang="pug">
.strand-new-discussion.context-panel#context(v-intersect.once="{handler: viewed}")
  strand-header.pt-3(:topicable="discussion")
  .mb-4.text-body-medium
    user-avatar.mr-2(:user='author')
    router-link.text-medium-emphasis.text-decoration-none(:to="urlFor(author)") {{authorName}}
    mid-dot
    router-link.text-medium-emphasis.text-decoration-none(:to='urlFor(discussion)')
      time-ago(:date='discussion.createdAt')

  template(v-if="!collapsed")
    formatted-text.context-panel__description(:model="discussion" field="description")
    link-previews(:model="discussion")
    attachment-list(:attachments="discussion.attachments")
    action-dock.py-2(:model='discussion' :actions='dockActions' :menu-actions='menuActions' variant="tonal")
</template>
<style lang="sass">
abbr[title]
  text-decoration: none
a
  cursor: pointer

.context-panel__heading-pin
  margin-left: 4px

.context-panel__discussion-privacy i
  position: relative
  font-size: 14px
  top: 2px

.context-panel__description
  > p:last-of-type
    margin-bottom: 24px

</style>
