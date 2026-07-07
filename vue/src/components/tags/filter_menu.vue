<script setup lang="js">
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import { ref, computed } from 'vue';

const { group, selectedTag } = defineProps({
  group: {
    type: Object,
    required: true
  },
  selectedTag: String
});

const emit = defineEmits(['select']);

const open = ref(false);
const filter = ref('');

const groupTags = computed(() => {
  return group.tags().slice().sort((a, b) => a.name.localeCompare(b.name));
});

const filteredGroupTags = computed(() => {
  const query = filter.value.trim().toLowerCase();
  if (!query) { return groupTags.value; }

  return groupTags.value.filter(tag => tag.name.toLowerCase().includes(query));
});

const canAdminTags = computed(() => group.parentOrSelf().adminsInclude(Session.user()));

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
  v-card.tags-filter-menu__card(min-width="280" max-width="360")
    .pa-2
      v-text-field(
        v-model="filter"
        :placeholder="$t('common.action.filter')"
        autofocus
        density="compact"
        hide-details
        prepend-inner-icon="mdi-magnify"
        variant="outlined"
      )
    v-list(density="compact")
      v-list-item.tags-filter-menu__all-tags(
        :active="!selectedTag"
        @click="selectTag(null)"
      )
        v-list-item-title(v-t="'loomio_tags.all_tags'")
        template(v-slot:append)
          common-icon(v-if="!selectedTag" name="mdi-check")
      v-list-item(
        v-for="tag in filteredGroupTags"
        :key="tag.id"
        :active="selectedTag == tag.name"
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

<style lang="sass">
.tags-filter-menu__selected-tag
  align-items: center
  display: inline-flex
  margin-left: -4px

.tags-filter-menu__selected-tag-dot
  height: 12px
  margin-right: 6px
  width: 12px

.tag-color-dot
  border-radius: 50%
  height: 16px
  margin-right: 12px
  width: 16px
</style>
