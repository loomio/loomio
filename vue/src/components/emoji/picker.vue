<script setup lang="js">
import { computed, onMounted, ref } from 'vue';
import { mdiMagnify } from '@mdi/js';
import { frequentEmojiEntries, loadEmojiEntries, searchEmojis, skinTones, tonedUnicode } from '@/shared/helpers/emojis';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';

const props = defineProps({
  isPoll: Boolean,
  insert: {
    type: Function,
    required: true
  }
});

const search = ref('');
const entries = ref([]);
const skinTone = ref(Session.user().experiences['emojiSkinTone'] || 0);
const skinMenuOpen = ref(false);
const searchField = ref(null);

const allEntries = computed(() => entries.value);
const frequentEntries = computed(() => frequentEmojiEntries(entries.value));
const searchResults = computed(() => searchEmojis(search.value, entries.value));
const activeSwatch = computed(() => skinTones.find(t => t.tone === skinTone.value) || skinTones[0]);

onMounted(() => {
  loadEmojiEntries(Session.user()?.locale).then(loadedEntries => {
    entries.value = loadedEntries;
  });
  focusSearch();
});

// Keep the caret in the search field for as long as the picker is open, so the
// user can start typing straight away. Double rAF runs after the enclosing
// menu's own open-focus handling, which would otherwise pull focus away.
function focusSearch() {
  requestAnimationFrame(() => requestAnimationFrame(() => {
    if (searchField.value) { searchField.value.focus(); }
  }));
}

function unicodeFor(entry) {
  return tonedUnicode(entry, skinTone.value);
}

function selectTone(tone) {
  skinTone.value = tone;
  Records.users.saveExperience('emojiSkinTone', tone);
  skinMenuOpen.value = false;
  focusSearch();
}

function pick(entry) {
  props.insert(entry.shortcode, unicodeFor(entry));
}
</script>

<template lang="pug">
v-sheet.emoji-picker.pa-2
  div.emoji-picker__search-wrapper(@click.stop)
    v-text-field.emoji-picker__search(
      ref="searchField"
      v-model="search"
      variant="outlined"
      density="compact"
      hide-details
      single-line
      clearable
      autofocus
      :placeholder="$t('emoji_picker.search')"
      :prepend-inner-icon="mdiMagnify"
    )
      template(v-slot:append-inner)
        v-menu(v-model="skinMenuOpen" location="bottom end" :close-on-content-click="false")
          template(v-slot:activator="{ props }")
            button.emoji-picker__skin-toggle(
              v-bind="props"
              type="button"
              @mousedown.prevent
              title="Skin tone"
              aria-label="Skin tone"
            )
              span.emoji-picker__swatch(:style="{ backgroundColor: activeSwatch.color }")
          v-list(density="compact" @click.stop)
            v-list-item(
              v-for="tone in skinTones"
              :key="tone.tone"
              :active="tone.tone === skinTone"
              @click.stop="selectTone(tone.tone)"
            )
              span.emoji-picker__swatch(:style="{ backgroundColor: tone.color }")
  template(v-if="search")
    .emoji-picker__emojis.emoji-picker__results
      span.emoji-picker__emoji(
        v-for="entry in searchResults"
        :key="entry.shortcode"
        :title="entry.label"
        @mousedown.prevent
        @click="pick(entry)"
      ) {{ unicodeFor(entry) }}
  template(v-else)
    .emoji-picker__emojis.emoji-picker__frequent
      span.emoji-picker__emoji(
        v-for="entry in frequentEntries"
        :key="entry.shortcode"
        :title="entry.label"
        @mousedown.prevent
        @click="pick(entry)"
      ) {{ unicodeFor(entry) }}
    .emoji-picker__emojis
      span.emoji-picker__emoji(
        v-for="entry in allEntries"
        :key="entry.shortcode"
        :title="entry.label"
        @mousedown.prevent
        @click="pick(entry)"
      ) {{ unicodeFor(entry) }}
</template>

<style lang="sass">
.emoji-picker
  width: min(330px, calc(100vw - 24px))
  min-width: min(304px, calc(100vw - 24px))
  max-height: 400px
  overflow-y: auto

.emoji-picker__search-wrapper
  display: flex
  align-items: center
  gap: 8px
  margin-bottom: 4px

.emoji-picker__search
  flex: 1 1 auto

.emoji-picker__skin-toggle
  flex: 0 0 auto
  display: flex
  align-items: center
  justify-content: center
  width: 32px
  height: 32px
  padding: 0
  border: none
  background: none
  border-radius: 4px
  cursor: pointer
  &:hover
    background-color: rgba(var(--v-theme-on-surface), 0.08)

.emoji-picker__swatch
  display: inline-block
  width: 20px
  height: 20px
  border-radius: 50%
  border: 1px solid rgba(var(--v-theme-on-surface), 0.24)

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
