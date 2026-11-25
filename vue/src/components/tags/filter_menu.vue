<script setup lang="js">
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import { ref, computed, watch } from 'vue';
import { uniqBy } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';

const { group, selectedTag } = defineProps({
  group: {
    type: Object,
    default: null
  },
  selectedTag: String
});

const emit = defineEmits(['select']);

const open = ref(false);
const filter = ref('');

watch(open, isOpen => {
  if (!isOpen) { filter.value = ''; }
});

const groupTags = computed(() => {
  const tags = group
    ? group.tags().slice()
    : uniqBy(Session.user().groups().flatMap(g => g.tags()), 'name');
  return tags.sort((a, b) => a.name.localeCompare(b.name));
});

const filteredGroupTags = computed(() => {
  const query = filter.value.trim().toLowerCase();
  if (!query) { return groupTags.value; }

  return groupTags.value.filter(tag => tag.name.toLowerCase().includes(query));
});

const canAdminTags = computed(() => Boolean(group) && group.parentOrSelf().adminsInclude(Session.user()));

const selectedTagRecord = computed(() => {
  return selectedTag ? groupTags.value.find(tag => tag.name === selectedTag) : null;
});

function tagDotStyle(tag) {
  return tag.color ? {backgroundColor: tag.color} : {};
}

function selectTag(tagName) {
  open.value = false;
  emit('select', tagName);
}

function openTagsSelect() {
  open.value = false;
  EventBus.$emit('openModal', {
    component: 'TagsSelect',
    props: { group }
  });
}
</script>

<template lang="pug">
v-menu.tags-filter-menu(v-model="open" offset-y :close-on-content-click="false")
  template(v-slot:activator="{ props }")
    v-btn.tags-filter-menu__button.mr-2.text-medium-emphasis(v-bind="props" variant="tonal")
      span.tags-filter-menu__selected-tag(v-if="selectedTagRecord")
        .tag-color-dot.tags-filter-menu__selected-tag-dot(:style="tagDotStyle(selectedTagRecord)")
        span {{ selectedTag }}
      span(v-else-if="selectedTag") {{ selectedTag }}
      span(v-else v-t="'loomio_tags.tags'")
      common-icon(name="mdi-menu-down")
  v-card.tags-filter-menu__card(min-width="240" max-width="360")
    .pa-2(v-if="groupTags.length > 8")
      v-text-field(
        v-model="filter"
        :placeholder="$t('group_cards.filter_tags')"
        autofocus
        density="compact"
        hide-details
        :prepend-inner-icon="mdiMagnify"
        variant="outlined"
      )
    v-list(density="compact" max-height="60vh")
      v-list-item.tags-filter-menu__all-tags(
        :active="!selectedTag"
        @click="selectTag(null)"
      )
        template(v-slot:prepend)
          common-icon.text-medium-emphasis.mr-3(name="mdi-tag-outline" size="16")
        v-list-item-title(v-t="'loomio_tags.all_tags'")
        template(v-slot:append)
          common-icon(v-if="!selectedTag" name="mdi-check")
      v-list-item.tags-filter-menu__tag(
        v-for="tag in filteredGroupTags"
        :key="tag.id"
        :active="selectedTag == tag.name"
        :data-tag-name="tag.name"
        @click="selectTag(tag.name)"
      )
        template(v-slot:prepend)
          .tag-color-dot(:style="tagDotStyle(tag)")
        v-list-item-title {{ tag.name }}
        template(v-slot:append)
          common-icon(v-if="selectedTag == tag.name" name="mdi-check")
      template(v-if="canAdminTags")
        v-divider
        v-list-item.tags-filter-menu__edit-tags(@click="openTagsSelect")
          template(v-slot:prepend)
            common-icon.text-medium-emphasis(name="mdi-tag-outline")
          v-list-item-title(v-t="'loomio_tags.edit_tags'")
</template>

<style>
.tags-filter-menu__selected-tag {
  align-items: center;
  display: inline-flex;
  margin-left: -4px;
}

.tags-filter-menu__selected-tag-dot {
  height: 12px;
  margin-right: 6px;
  width: 12px;
}

.tag-color-dot {
  border-radius: 50%;
  height: 16px;
  margin-right: 12px;
  width: 16px;
}
</style>
