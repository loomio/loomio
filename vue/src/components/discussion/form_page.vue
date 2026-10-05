<script setup lang="js">
import { ref, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';

import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';

const route = useRoute();

const discussion = ref(null);
const user = ref(null);

const loadDiscussion = async () => {
  let discussionId, templateId, templateKey, userId;

  if (route.params.key) {
    const discussion = await Records.discussions.findOrFetchById(route.params.key);
    return discussion.clone();

  } else if ((templateId = parseInt(route.query.template_id))) {
    const template = await Records.discussionTemplates.findOrFetchById(templateId);
    const discussion = template.buildDiscussion();
    if (!template.defaultToDirectDiscussion && parseInt(route.query.group_id)) {
      discussion.groupId = parseInt(route.query.group_id);
    }
    return discussion;

  } else if ((templateKey = route.query.template_key)) {
    const template = await Records.discussionTemplates.findOrFetchByKey(templateKey, route.query.group_id);
    const discussion = template.buildDiscussion();
    if (!template.defaultToDirectDiscussion && parseInt(route.query.group_id)) {
      discussion.groupId = parseInt(route.query.group_id);
    }
    return discussion;

  } else if ((discussionId = parseInt(route.query.discussion_id))) {
    const original = await Records.discussions.findOrFetchById(discussionId);
    const discussion = original.buildCopy();
    if (original.groupId && Session.user().groupIds().includes(original.groupId)) {
      discussion.groupId = original.groupId;
    }
    return discussion;

  } else if (parseInt(route.query.group_id)) {
    const groupId = parseInt(route.query.group_id);
    await Records.groups.findOrFetchById(groupId);
    return Records.discussions.build({
      title: route.query.title,
      groupId: groupId,
      descriptionFormat: Session.defaultFormat()
    });

  } else if ((userId = parseInt(route.query.user_id))) {
    user.value = await Records.users.findOrFetchById(userId);
    return Records.discussions.build({
      title: route.query.title,
      groupId: null,
      descriptionFormat: Session.defaultFormat()
    });

  } else {
    return Records.discussions.build({
      title: route.query.title,
      descriptionFormat: Session.defaultFormat()
    });
  }
};

// Every route-based load must show access failures instead of leaving a blank
// form. Signing in clears the app's error page and retries the current route.
const init = async () => {
  discussion.value = null;
  try {
    discussion.value = await loadDiscussion();
  } catch (error) {
    if (!error.status) { throw error; }
    EventBus.$emit('pageError', error);
    if (error.status === 403 && !Session.isSignedIn()) {
      EventBus.$emit('openAuthModal');
    }
  }
};

onMounted(() => {
  init();
  EventBus.$emit('content-title-visible', false);
  const isEdit = !!route.params.key;
  EventBus.$emit('currentComponent', {
    titleKey: isEdit ? 'discussion_form.edit_discussion_context' : 'discussion_form.new_discussion_title',
    page: 'discussionFormPage'
  });
});

watch(() => route.query, () => { init(); });
watch(() => route.params.key, () => { init(); });
</script>

<template lang="pug">
v-main
  v-container.start-discussion-page.max-width-800.px-0.px-sm-3
    discussion-form(
      v-if="discussion"
      :discussion='discussion'
      is-page
      :key="discussion.id"
      :user="user")
</template>
