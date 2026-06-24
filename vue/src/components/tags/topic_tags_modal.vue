<script setup lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash    from '@/shared/services/flash';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted } from 'vue';

const { topic, initialTags, close } = defineProps({
  topic: {
    type: Object,
    required: true
  },
  // Selected tag names, passed back when returning from the create-tag modal
  // so in-progress selections survive the round trip.
  initialTags: Array,
  close: Function
});

const { watchRecords } = useWatchRecords();

const loading = ref(false);
const query = ref('');
const selectedTags = ref((initialTags || topic.tags || []).slice());
const allTags = ref([]);
const tagGroup = ref(null);

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

function loadGroup(group) {
  tagGroup.value = group;
  allTags.value = group.tags();
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
      allTags.value = tagsFromNames(topic.tags || []);
    }
  });
}

onMounted(() => {
  loadTags();
  watchRecords({
    key: 'topicTags' + topic.id,
    collections: ['tags'],
    query: () => { loadTags(); }
  });
});

const trimmedQuery = computed(() => (query.value || '').trim());

const filteredTags = computed(() => {
  const q = trimmedQuery.value.toLowerCase();
  if (!q) { return allTags.value; }
  return allTags.value.filter(tag => tag.name.toLowerCase().includes(q));
});

const hasExactMatch = computed(() => {
  const q = trimmedQuery.value.toLowerCase();
  return allTags.value.some(tag => tag.name.toLowerCase() === q);
});

const canCreateTags = computed(() => usableGroup(tagGroup.value));

function isSelected(tag) {
  return selectedTags.value.includes(tag.name);
}

function toggle(tag) {
  const i = selectedTags.value.indexOf(tag.name);
  if (i === -1) { selectedTags.value.push(tag.name); } else { selectedTags.value.splice(i, 1); }
}

function openNewTagModal() {
  if (!usableGroup(tagGroup.value)) { return; }

  const group = tagGroup.value;
  const tag = Records.tags.build({groupId: group.id, name: trimmedQuery.value});
  EventBus.$emit('openModal', {
    component: 'TagsModal',
    props: {
      tag,
      close: () => {
        const selected = selectedTags.value.slice();
        // tag was built with Records.tags.build() (not in the collection);
        // after save, importJSON creates a new record — the built object
        // never gets its id set, so look up the saved tag by name instead.
        const savedTag = Records.tags.find({groupId: group.id, name: tag.name})[0];
        if (tag.name && !selected.includes(tag.name) && savedTag) { selected.push(tag.name); }
        EventBus.$emit('openModal', {
          component: 'TopicTagsModal',
          props: {topic, initialTags: selected}
        });
      }
    }
  });
}

function submit() {
  loading.value = true;
  topic.tags = selectedTags.value;
  topic.save().then(() => {
    close();
  }).catch(err => Flash.serverError(err)).finally(() => {
    loading.value = false;
  });
}
</script>

<template lang="pug">
v-card.topic-tags-modal(:title="$t('loomio_tags.apply_tags')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    v-text-field.topic-tags-modal__filter(
      v-model="query"
      :label="$t('loomio_tags.filter_placeholder')"
      prepend-inner-icon="mdi-magnify"
      clearable
      autofocus
      hide-details
    )
    v-list.topic-tags-modal__list
      v-list-item.topic-tags-modal__tag(
        v-for="tag in filteredTags"
        :key="tag.id"
        @click="toggle(tag)"
      )
        template(v-slot:prepend)
          v-checkbox-btn(:model-value="isSelected(tag)" readonly)
        v-chip(:color="tag.color" size="small") {{ tag.name }}
      v-list-item.topic-tags-modal__create(
        v-if="canCreateTags && !(trimmedQuery && hasExactMatch)"
        @click="openNewTagModal"
      )
        template(v-slot:prepend)
          common-icon(name="mdi-plus")
        span(v-if="trimmedQuery" v-t="{path: 'loomio_tags.new_named_tag', args: {name: trimmedQuery}}")
        span(v-else v-t="'loomio_tags.new_tag'")
  v-card-actions
    v-spacer
    v-btn.topic-tags-modal__submit(variant="elevated" color="primary" @click="submit" :loading="loading")
      span(v-t="'common.action.save'")
</template>

<style lang="sass">
// Align the "New tag" plus icon with the tag checkboxes above it
// (the checkbox control is 40px wide; v-icon centres its glyph).
.topic-tags-modal__create .v-list-item__prepend .v-icon
  width: 40px
</style>
