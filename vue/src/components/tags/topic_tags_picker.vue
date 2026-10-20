<script setup lang="js">
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
import AbilityService from '@/shared/services/ability_service';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';

const { topic, topicItem, watchKey } = defineProps({
  topic: {
    type: Object,
    required: true
  },
  topicItem: Object,
  watchKey: {
    type: String,
    required: true
  }
});

const { watchRecords } = useWatchRecords();
const { t } = useI18n();
const assignedTags = () => topicItem ? topicItem.tags : topic.rootTags;

const selectedTags = ref([]);
const orgTags = ref([]);
const tagGroup = ref(null);
const addingTag = ref(false);
const newTagName = ref('');
const showOtherGroupTags = ref(false);
let savePromise = Promise.resolve();
let saveSequence = 0;

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
      orgTags.value = sortedTags(tagsFromNames(assignedTags()));
    }
  });
}

function reset() {
  selectedTags.value = cleanTagNames(assignedTags());
  addingTag.value = false;
  newTagName.value = '';
  loadTags();
}

defineExpose({ reset });

onMounted(() => {
  selectedTags.value = cleanTagNames(assignedTags());
  loadTags();
  watchRecords({
    key: watchKey,
    collections: ['tags'],
    query: () => { loadTags(); }
  });
});

const canCreateTags = computed(() => {
  if (!topic.groupId) { return true; }

  if (!usableGroup(tagGroup.value)) { return false; }

  return AbilityService.canCreateTags(tagGroup.value);
});

const hasOtherGroups = computed(() => usableGroup(tagGroup.value) && tagGroup.value.parentOrSelf().subgroupsCount > 0);

// Unused vocabulary stays available locally. Only tags used exclusively in
// other groups need expanding; an organization with one group has no expansion.
function tagFromOtherGroup(tag) {
  return hasOtherGroups.value && tag.usedGroupIds.length > 0 && !tag.usedGroupIds.includes(tagGroup.value.id);
}

const hasOtherGroupTags = computed(() => orgTags.value.some(tag => tagFromOtherGroup(tag) && !isSelected(tag)));

const allTags = computed(() => {
  const tags = orgTags.value.filter(tag => !tagFromOtherGroup(tag) || isSelected(tag) || showOtherGroupTags.value);
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
  const sequence = ++saveSequence;
  const tags = cleanTagNames(selectedTags.value);
  selectedTags.value = tags;
  savePromise = savePromise.catch(() => {}).then(() => {
    const remote = topicItem ? Records.topicItems.remote : Records.topics.remote;
    const id = topicItem ? topicItem.id : topic.id;
    return remote.patchMember(id, 'tags', {tags}).then(() => {
      if (sequence === saveSequence) { selectedTags.value = cleanTagNames(assignedTags()); }
    }).catch(err => {
      if (sequence === saveSequence) { selectedTags.value = cleanTagNames(assignedTags()); }
      Flash.serverError(err);
    });
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
    v-list-item.topic-tags-picker__all-tags(v-if="hasOtherGroupTags" density="compact" @click="showOtherGroupTags = !showOtherGroupTags")
      template(v-slot:prepend)
        common-icon.text-medium-emphasis(:name="showOtherGroupTags ? 'mdi-unfold-less-horizontal' : 'mdi-unfold-more-horizontal'")
      v-list-item-title(v-if="showOtherGroupTags") {{ t('loomio_tags.show_tags_used_in_this_group') }}
      v-list-item-title(v-else) {{ t('loomio_tags.show_tags_from_other_groups') }}
      v-list-item-subtitle(v-if="!showOtherGroupTags") {{ t('loomio_tags.parent_group_and_subgroups_in_this_organization') }}
    v-list-item.topic-tags-picker__new-tag(v-if="canCreateTags && !addingTag" density="compact" @click="openNewTagModal")
      template(v-slot:prepend)
        common-icon.text-medium-emphasis(name="mdi-tag-plus-outline")
      span {{ t('loomio_tags.new_tag') }}
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

<style>
.topic-tags-picker__tag-content {
  align-items: center;
  display: flex;
}

.tag-color-dot {
  border-radius: 50%;
  height: 16px;
  margin-right: 12px;
  width: 16px;
}

.topic-tags-picker__all-tags .v-list-item-subtitle {
  line-clamp: unset;
  -webkit-line-clamp: unset;
}
</style>
