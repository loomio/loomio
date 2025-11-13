<script setup lang="js">
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import ThreadService from '@/shared/services/thread_service';
import { omit, pickBy } from 'lodash-es';
import Session from '@/shared/services/session';
import openModal from '@/shared/helpers/open_modal';
import StrandActionsPanel from '@/components/strand/actions_panel';
import { useUrlFor } from '@/shared/composables/use_url_for';

const props = defineProps({
  event: Object,
  eventable: Object,
  collapsed: Boolean
});

const route = useRoute();
const { urlFor } = useUrlFor();

const groups = ref([]);
const actions = ref([]);

const discussion = computed(() => props.eventable);

const author = computed(() => {
  return discussion.value.author();
});

const authorName = computed(() => {
  return discussion.value.authorName();
});

const group = computed(() => {
  return discussion.value.group();
});

const dockActions = computed(() => {
  return pickBy(actions.value, v => v.dock);
});

const menuActions = computed(() => {
  return pickBy(actions.value, v => v.menu);
});

const status = computed(() => {
  if (discussion.value.pinned) { return 'pinned'; }
});

const rebuildActions = () => {
  actions.value = omit(ThreadService.actions(props.eventable, this), ['dismiss_thread']);
};

const updateGroups = () => {
  groups.value = discussion.value.group().parentsAndSelf().map(group => {
    return {
      title: group.name,
      disabled: false,
      to: group.id ? urlFor(group) : '/threads/direct'
    };
  });
};

const viewed = (isViewed) => {
  if (isViewed && Session.isSignedIn()) {
    discussion.value.markAsSeen();
    if (Session.user().autoTranslate && actions.value['translate_thread'] && actions.value['translate_thread'].canPerform()) {
      actions.value['translate_thread'].perform().then(() => { rebuildActions(); });
    }
  }
};

const openSeenByModal = () => {
  openModal({
    component: 'SeenByModal',
    persistent: false,
    props: {
      discussion: discussion.value,
    }
  });
};

onMounted(() => {
  props.eventable.fetchUsersNotifiedCount();
  updateGroups();
  rebuildActions();
});

watch(() => props.eventable.newestFirst, () => {
  rebuildActions();
});

watch(() => discussion.value.groupId, () => {
  updateGroups();
});
</script>

<template lang="pug">
.strand-new-discussion.context-panel#context(v-intersect.once="{handler: viewed}")
  .d-flex.ml-n3.text-body-2
    v-breadcrumbs.context-panel__breadcrumbs(color="anchor" :items="groups")
      template(v-slot:divider)
        common-icon(name="mdi-chevron-right")
    v-spacer
    tags-display(:tags="discussion.tags" :group="discussion.group()")

  strand-title.text-high-emphasis(:discussion="discussion")

  .mb-4.text-body-2
    user-avatar.mr-2(:user='author')
    router-link.text-medium-emphasis(:to="urlFor(author)") {{authorName}}
    mid-dot
    router-link.text-medium-emphasis(:to='urlFor(discussion)')
      time-ago(:date='discussion.createdAt')
    span.text-medium-emphasis(v-show='discussion.seenByCount > 0')
      mid-dot
      a.context-panel__seen_by_count.underline-on-hover(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")
    span.text-medium-emphasis(v-show='discussion.usersNotifiedCount != null')
      mid-dot
      a.context-panel__users_notified_count.underline-on-hover(v-t="{ path: 'thread_context.count_notified', args: { count: discussion.usersNotifiedCount} }"  @click="actions.notification_history.perform")

  template(v-if="!collapsed")
    formatted-text.context-panel__description(:model="discussion" field="description")
    link-previews(:model="discussion")
    document-list(:model='discussion')
    attachment-list(:attachments="discussion.attachments")
    action-dock.py-2(:model='discussion' :actions='dockActions' :menu-actions='menuActions' color="primary" variant="tonal")
</template>
<style lang="sass">
abbr[title]
  text-decoration: none
a
  cursor: pointer

.context-panel__heading-pin
  margin-left: 4px

.context-panel
  .v-breadcrumbs
    padding: 4px 10px 4px 10px
    // margin-left: 0;

.context-panel__discussion-privacy i
  position: relative
  font-size: 14px
  top: 2px

.context-panel__description
  > p:last-of-type
    margin-bottom: 24px

</style>