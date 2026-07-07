<script setup lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import AbilityService from '@/shared/services/ability_service';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted } from 'vue';

const { topic, watchKey } = defineProps({
  topic: {
    type: Object,
    required: true
  },
  watchKey: {
    type: String,
    required: true
  }
});

const emit = defineEmits(['beforeOpenExternal', 'close']);

const { watchRecords } = useWatchRecords();

const loading = ref(false);
const selectedTags = ref((topic.tags || []).slice());
const allTags = ref([]);
const tagGroup = ref(null);
const addingTag = ref(false);
const newTagName = ref('');

function cleanTagName(name) {
  return String(name || '').trim().split(/\s+/).filter(Boolean).join(' ');
}

function tagsFromNames(names, group) {
  const byName = {};
  if (group && !group.isNullGroup) {
    group.tags().forEach(tag => byName[tag.name] = tag);
  }

  return (names || []).map((name, i) => ({
    id: `template-tag-${i}`,
    name,
    color: (byName[name] || {}).color
  }));
}

function usableGroup(group) {
  return group && !group.isNullGroup;
}

function sortedTags(tags) {
  return tags.slice().sort((a, b) => a.name.localeCompare(b.name));
}

function loadGroup(group) {
  tagGroup.value = group;
  allTags.value = sortedTags(group.tags());
}

function fetchTemplateGroup(template) {
  if (!template || !template.groupId) { return Promise.resolve(null); }

  return Records.groups.findOrFetch(template.groupId).then(group => {
    return usableGroup(group) ? group : template.group();
  });
}

function fetchDirectTemplateGroup() {
  if (topic.topicableType === 'Discussion') {
    const discussion = topic.discussion();
    if (!discussion || !discussion.discussionTemplateId) { return Promise.resolve(null); }

    return Records.discussionTemplates.findOrFetchById(discussion.discussionTemplateId).then(fetchTemplateGroup);
  }

  if (topic.topicableType === 'Poll') {
    const poll = topic.topicable();
    if (!poll || !poll.pollTemplateId) { return Promise.resolve(null); }

    return Records.pollTemplates.findOrFetchById(poll.pollTemplateId).then(fetchTemplateGroup);
  }

  return Promise.resolve(null);
}

function loadTags() {
  if (topic.groupId) {
    loadGroup(topic.group());
    return;
  }

  tagGroup.value = null;
  fetchDirectTemplateGroup().then(group => {
    if (usableGroup(group)) {
      loadGroup(group);
    } else {
      allTags.value = sortedTags(tagsFromNames(topic.tags || []));
    }
  });
}

function reset() {
  selectedTags.value = (topic.tags || []).slice();
  addingTag.value = false;
  newTagName.value = '';
  loadTags();
}

defineExpose({ reset });

onMounted(() => {
  loadTags();
  watchRecords({
    key: watchKey,
    collections: ['tags'],
    query: () => { loadTags(); }
  });
});

const canAdminTags = computed(() => usableGroup(tagGroup.value) && AbilityService.canAdminTags(topic));
const canCreateTags = computed(() => usableGroup(tagGroup.value));

function isSelected(tag) {
  return selectedTags.value.includes(tag.name);
}

function toggle(tag) {
  const i = selectedTags.value.indexOf(tag.name);
  if (i === -1) { selectedTags.value.push(tag.name); } else { selectedTags.value.splice(i, 1); }
}

function openTagsSelect() {
  if (!canAdminTags.value) { return; }

  emit('beforeOpenExternal');
  EventBus.$emit('openModal', {
    component: 'TagsSelect',
    props: {
      group: tagGroup.value
    }
  });
}

function saveTags() {
  topic.tags = selectedTags.value;
  return Records.topics.remote.patchMember(topic.id, 'tags', {tags: selectedTags.value}).catch(err => Flash.serverError(err));
}

function openNewTagModal() {
  if (!canCreateTags.value) { return; }

  addingTag.value = true;
}

function submit() {
  loading.value = true;
  saveTags().then(() => {
    emit('close');
  }).finally(() => {
    loading.value = false;
  });
}

function submitNewTag() {
  const name = cleanTagName(newTagName.value);
  if (!name) { return; }

  const selectedKeys = selectedTags.value.map(tag => cleanTagName(tag).toLowerCase());
  if (!selectedKeys.includes(name.toLowerCase())) { selectedTags.value.push(name); }
  newTagName.value = '';
  addingTag.value = false;
}
</script>

<template lang="pug">
.topic-tags-picker
  v-list.topic-tags-picker__list(density="compact")
    v-list-item.topic-tags-picker__tag(
      density="compact"
      v-for="tag in allTags"
      :key="tag.id"
      @click="toggle(tag)"
    )
      template(v-slot:prepend)
        v-checkbox-btn(:model-value="isSelected(tag)" readonly)
      v-chip(:color="tag.color" size="small")
        span.text-on-surface {{ tag.name }}
    v-list-item.topic-tags-picker__new-tag(v-if="canCreateTags && !addingTag" density="compact" @click="openNewTagModal")
      span(v-t="'loomio_tags.new_tag'")
    v-list-item.topic-tags-picker__new-tag-input(v-if="addingTag" density="compact")
      v-text-field(
        v-model="newTagName"
        :label="$t('loomio_tags.name_label')"
        autofocus
        density="compact"
        hide-details
        @keyup.enter="submitNewTag"
      )
      template(v-slot:append)
        v-btn(icon size="small" variant="text" @click="submitNewTag")
          common-icon(name="mdi-check")
  v-divider
  v-card-actions
    v-btn.topic-tags-picker__edit-tags(v-if="canAdminTags" variant="text" @click="openTagsSelect")
      span(v-t="'loomio_tags.edit_tags'")
    v-spacer
    v-btn.topic-tags-picker__submit(variant="elevated" color="primary" @click="submit" :loading="loading")
      span(v-t="'common.action.save'")
</template>


