<script setup lang="js">
import { ref, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';

import Records from '@/shared/services/records';
import Session from '@/shared/services/session';

const route = useRoute();

const discussion = ref(null);
const user = ref(null);

const init = () => {
  let discussionId, templateId, templateKey, userId;
  discussion.value = null;

  if (route.params.key) {
    Records.discussions.findOrFetchById(route.params.key).then(d => {
      discussion.value = d.clone();
    });

  } else if ((templateId = parseInt(route.query.template_id))) {
    Records.discussionTemplates.findOrFetchById(templateId).then(template => {
      discussion.value = template.buildDiscussion();
      if (!template.defaultToDirectDiscussion && parseInt(route.query.group_id)) {
        discussion.value.groupId = parseInt(route.query.group_id);
      }
    });

  } else if ((templateKey = route.query.template_key)) {
    Records.discussionTemplates.findOrFetchByKey(route.query.template_key, route.query.group_id).then(template => {
      discussion.value = template.buildDiscussion();
      if (!template.defaultToDirectDiscussion && parseInt(route.query.group_id)) {
        discussion.value.groupId = parseInt(route.query.group_id);
      }
    });

  } else if ((discussionId = parseInt(route.query.discussion_id))) {
    Records.discussions.findOrFetchById(discussionId).then(dt => {
      discussion.value = dt.buildCopy();
      if (dt.groupId && Session.user().groupIds().includes(dt.groupId)) {
        discussion.value.groupId = dt.groupId;
      }
    });

  } else if (parseInt(route.query.group_id)) {
    const groupId = parseInt(route.query.group_id);
    Records.groups.findOrFetchById(groupId).then(() => {
      discussion.value = Records.discussions.build({
        title: route.query.title,
        groupId: groupId,
        descriptionFormat: Session.defaultFormat()
      });
    });

  } else if ((userId = parseInt(route.query.user_id))) {
    Records.users.findOrFetchById(userId).then(u => {
      user.value = u;
      discussion.value = Records.discussions.build({
        title: route.query.title,
        groupId: null,
        descriptionFormat: Session.defaultFormat()
      });
    });

  } else {
    discussion.value = Records.discussions.build({
      title: route.query.title,
      descriptionFormat: Session.defaultFormat()
    });
  }
};

onMounted(() => {
  init();
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
