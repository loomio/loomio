<script setup lang="js">
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
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

const { watchRecords } = useWatchRecords();

const selectedTags = ref([]);
const orgTags = ref([]);
const tagGroup = ref(null);
const addingTag = ref(false);
const newTagName = ref('');
const showAllTags = ref(false);
let savePromise = Promise.resolve();

function cleanTagName(name) {
  return String(name || '').trim().split(/\s+/).filter(Boolean).join(' ');
}

function cleanTagNames(names) {
  const seen = {};
  return (names || []).map(cleanTagName).filter(name => {
    const key = name.toLowerCase();
    if (!key || seen[key]) { return false; }

    seen[key] = true;
    return true;
  }).sort((a, b) => a.localeCompare(b));
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

function tagDotStyle(tag) {
  return tag.color ? {backgroundColor: tag.color} : {};
}

function loadGroup(group) {
  tagGroup.value = group;
  orgTags.value = sortedTags(group.tags());
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
      orgTags.value = sortedTags(tagsFromNames(topic.tags || []));
    }
  });
}

function reset() {
  selectedTags.value = cleanTagNames(topic.tags || []);
  addingTag.value = false;
  newTagName.value = '';
  loadTags();
}

defineExpose({ reset });

onMounted(() => {
  selectedTags.value = cleanTagNames(topic.tags || []);
  loadTags();
  watchRecords({
    key: watchKey,
    collections: ['tags'],
    query: () => { loadTags(); }
  });
});

const canCreateTags = computed(() => usableGroup(tagGroup.value));

function tagVisibleInCurrentGroup(tag) {
  return showAllTags.value ||
    isSelected(tag) ||
    (tag.usedGroupIds || []).includes(tagGroup.value.id);
}

const allTags = computed(() => {
  const tags = usableGroup(tagGroup.value) ? orgTags.value.filter(tagVisibleInCurrentGroup) : orgTags.value;
  const tagKeys = tags.map(tag => cleanTagName(tag.name).toLowerCase());
  const selectedWithoutMetadata = selectedTags.value.filter(name => !tagKeys.includes(cleanTagName(name).toLowerCase()));

  return sortedTags(tags.concat(tagsFromNames(selectedWithoutMetadata, tagGroup.value)));
});

function isSelected(tag) {
  return selectedTags.value.includes(tag.name);
}

function toggle(tag) {
  const i = selectedTags.value.indexOf(tag.name);
  if (i === -1) { selectedTags.value.push(tag.name); } else { selectedTags.value.splice(i, 1); }
  selectedTags.value = cleanTagNames(selectedTags.value);
  saveTags();
}

function saveTags() {
  const tags = cleanTagNames(selectedTags.value);
  selectedTags.value = tags;
  topic.tags = tags;
  savePromise = savePromise.catch(() => {}).then(() => {
    return Records.topics.remote.patchMember(topic.id, 'tags', {tags}).catch(err => Flash.serverError(err));
  });
  return savePromise;
}

function openNewTagModal() {
  if (!canCreateTags.value) { return; }

  addingTag.value = true;
}

function submitNewTag() {
  const name = cleanTagName(newTagName.value);
  if (!name) {
    addingTag.value = false;
    return;
  }

  const selectedKeys = selectedTags.value.map(tag => cleanTagName(tag).toLowerCase());
  if (!selectedKeys.includes(name.toLowerCase())) {
    selectedTags.value.push(name);
    selectedTags.value = cleanTagNames(selectedTags.value);
    saveTags();
  }
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
      .topic-tags-picker__tag-content
        .tag-color-dot(:style="tagDotStyle(tag)")
        span {{ tag.name }}
    v-list-item.topic-tags-picker__all-tags(v-if="canCreateTags" density="compact" @click="showAllTags = !showAllTags")
      template(v-slot:prepend)
        common-icon.text-medium-emphasis(name="mdi-unfold-more-horizontal")
      v-list-item-title(v-if="showAllTags" v-t="'common.action.show_fewer'")
      v-list-item-title(v-else v-t="'common.action.show_more'")
      v-list-item-subtitle(v-if="showAllTags" v-t="'loomio_tags.only_show_tags_in_this_group'")
      v-list-item-subtitle(v-else v-t="'loomio_tags.show_all_tags_in_organization'")
    v-list-item.topic-tags-picker__new-tag(v-if="canCreateTags && !addingTag" density="compact" @click="openNewTagModal")
      template(v-slot:prepend)
        common-icon.text-medium-emphasis(name="mdi-tag-plus-outline")
      span(v-t="'loomio_tags.new_tag'")
    .topic-tags-picker__new-tag-input.px-4.py-2(v-if="addingTag")
      v-text-field(
        v-model="newTagName"
        :label="$t('loomio_tags.name_label')"
        append-inner-icon="mdi-check"
        autofocus
        density="compact"
        hide-details
        variant="outlined"
        @click:append-inner="submitNewTag"
        @keyup.enter="submitNewTag"
      )
</template>

<style lang="sass">
.topic-tags-picker__tag-content
  align-items: center
  display: flex

.tag-color-dot
  border-radius: 50%
  height: 16px
  margin-right: 12px
  width: 16px

.topic-tags-picker__all-tags
  .v-list-item-subtitle
    line-clamp: unset
    -webkit-line-clamp: unset
</style>
