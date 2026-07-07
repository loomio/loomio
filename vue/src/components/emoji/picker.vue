<script setup lang="js">
import { computed, onMounted, ref } from 'vue';
import { frequentEmojiEntries, loadEmojiEntries, searchEmojis } from '@/shared/helpers/emojis';
import Session from '@/shared/services/session';

const props = defineProps({
  isPoll: Boolean,
  insert: {
    type: Function,
    required: true
  }
});

const search = ref('');
const entries = ref([]);

const allEntries = computed(() => entries.value);
const frequentEntries = computed(() => frequentEmojiEntries(entries.value));
const searchResults = computed(() => searchEmojis(search.value, entries.value));

onMounted(() => {
  loadEmojiEntries(Session.user()?.locale).then(loadedEntries => {
    entries.value = loadedEntries;
  });
});

function pick(entry) {
  props.insert(entry.shortcode, entry.unicode);
}
</script>

<template lang="pug">
v-sheet.emoji-picker.pa-2
  div.emoji-picker__search-wrapper(@click.stop)
    v-text-field.emoji-picker__search(
      v-model="search"
      variant="outlined"
      density="compact"
      hide-details
      single-line
      clearable
      :placeholder="$t('emoji_picker.search')"
      prepend-inner-icon="mdi-magnify"
    )
  template(v-if="search")
    .emoji-picker__emojis.emoji-picker__results
      span.emoji-picker__emoji(
        v-for="entry in searchResults"
        :key="entry.shortcode"
        :title="entry.label"
        @click="pick(entry)"
      ) {{ entry.unicode }}
  template(v-else)
    h5.emoji-picker__heading(v-t="'emoji_picker.common'")
    .emoji-picker__emojis.emoji-picker__frequent
      span.emoji-picker__emoji(
        v-for="entry in frequentEntries"
        :key="entry.shortcode"
        :title="entry.label"
        @click="pick(entry)"
      ) {{ entry.unicode }}
    .emoji-picker__emojis
      span.emoji-picker__emoji(
        v-for="entry in allEntries"
        :key="entry.shortcode"
        :title="entry.label"
        @click="pick(entry)"
      ) {{ entry.unicode }}
</template>

<style lang="sass">
.emoji-picker
  width: min(330px, calc(100vw - 24px))
  min-width: min(304px, calc(100vw - 24px))
  max-height: 400px
  overflow-y: auto

.emoji-picker__search-wrapper
  margin-bottom: 4px

.emoji-picker__search
  // v-text-field's own padding handles spacing

.emoji-picker__heading
  font-weight: normal
  margin-top: 4px

.emoji-picker__emojis
  display: flex
  flex-direction: row
  flex-wrap: wrap
  font-size: 24px
  margin-bottom: 12px

.emoji-picker__frequent
  margin-bottom: 16px

.emoji-picker__results
  min-height: 144px

.emoji-picker__emoji
  width: 32px
  height: 32px
  display: flex
  align-items: center
  justify-content: center
  cursor: pointer
  margin: 2px
  border-radius: 4px
  &:hover
    background-color: rgba(var(--v-theme-on-surface), 0.08)
</style>
