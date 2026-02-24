<script setup>
import Session      from '@/shared/services/session';
import Records      from '@/shared/services/records';
import NullGroupModel   from '@/shared/models/null_group_model';
import { I18n } from '@/i18n';
import PollCommonChooseTemplate from '@/components/poll/common/choose_template';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref } from 'vue';

const props = defineProps({
  topic: Object,
});

const emit = defineEmits(['setPoll']);

const selectedGroup = ref(props.topic.group());

const discussionTemplateId = props.topic.discussion() && props.topic.discussion().discussionTemplateId

if (discussionTemplateId) {
  Records.discussionTemplates.findOrFetchById(discussionTemplateId).then(dt => {
    const g = dt.group();
    if (g) { selectedGroup.value = g; }
  });
}
const groups = ref([]);

function fillGroups() {
  const defaultsGroup = new NullGroupModel();
  defaultsGroup.isNullGroup = false;
  defaultsGroup.name = I18n.global.t('templates.loomio_default_templates');
  const result = [defaultsGroup];
  const groupIds = Session.user().groupIds();
  Records.groups.collection.chain().
               find({id: { $in: groupIds }, archivedAt: null, parentId: null}).
               data().forEach(function(parent) {
    if (parent.pollTemplatesCount) { result.push(parent); }
    Records.groups.collection.chain().
               find({id: { $in: groupIds }, archivedAt: null, parentId: parent.id}).
               data().forEach(function(subgroup) {
      if (subgroup.pollTemplatesCount) { result.push(subgroup); }
    });
  });
  groups.value = result;
}

function selectGroup(group) { selectedGroup.value = group; }
function setPoll(poll) { emit('setPoll', poll); }

const { watchRecords } = useWatchRecords();
watchRecords({
  collections: ['groups'],
  query: () => fillGroups()
});
</script>

<template lang="pug">
div
  .poll-templates-select-group(v-if="selectedGroup.isNullGroup")
    p(v-t="'templates.which_templates_would_you_like_to_use'")
    v-list
      v-list-item(v-for="group in groups" :key="group.id" @click="selectGroup(group)")
        template(v-slot:prepend)
          group-avatar(:group="group" v-if="!group.parentId")
        v-list-item-title {{group.name}}
  poll-common-choose-template(
    v-else
    @setPoll="setPoll"
    :topic="topic"
    :group="selectedGroup")
</template>
