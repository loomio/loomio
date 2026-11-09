<script setup>
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { mdiChevronDown } from '@mdi/js';
import EventBus from '@/shared/services/event_bus';
import { observeResize } from '@/shared/helpers/observe_resize';
import { observeSelection } from '@/shared/helpers/observe_selection';

const { state, focused = false } = defineProps({state: Object, focused: Boolean});
const { t } = useI18n();
const viewport = ref(null);
const content = ref(null);
const overflowing = ref(false);
const folded = computed(() => !!state?.readBeforeVisit && !state.revealed && !focused && !state.announcedSinceRead);
let stopObserving;
let stopSelecting;

function reveal() {
  state?.reveal();
  stopObserving?.();
  stopSelecting?.();
}

// The preview height lives in CSS. Release bodies shorter than 1.5 previews, so
// readers never select Show more for a few hidden lines. A released body stays
// open for the visit, so late media cannot fold content that was visible.
function measure() {
  overflowing.value = content.value.getBoundingClientRect().height >= viewport.value.getBoundingClientRect().height * 1.5;
  if (!overflowing.value) reveal();
}

watch(() => focused || state?.announcedSinceRead, value => {
  if (value) reveal();
}, {flush: 'post'});

onMounted(() => {
  if (focused || state?.announcedSinceRead) {
    reveal();
  } else if (folded.value) {
    measure();
    if (folded.value) {
      stopObserving = observeResize(content.value, measure);
      stopSelecting = observeSelection(content.value, revealSelection);
    }
  }
});
onUnmounted(() => { stopObserving?.(); stopSelecting?.(); });

async function revealFocusedContent(event) {
  if (!folded.value) return;
  // Clicking plain text focuses this container. Use the button's action so
  // expansion preserves the viewport; only focused descendants need scrolling.
  if (event.target === content.value) return showMore();
  EventBus.$emit('cancelAutoScroll');
  reveal();
  await nextTick();
  event.target.scrollIntoView({block: 'nearest'});
}

async function showMore() {
  EventBus.$emit('cancelAutoScroll');
  reveal();
  await nextTick();
  content.value.focus({preventScroll: true});
}

// Browsers reach clipped text in two ways. Some scroll the clipped viewport
// itself. Reveal the body and move the page by the same distance, so the text
// the browser brought into view stays where the reader sees it.
async function revealScrolledContent() {
  const offset = viewport.value.scrollTop;
  if (!folded.value || offset === 0) return;
  EventBus.$emit('cancelAutoScroll');
  reveal();
  await nextTick();
  window.scrollBy({top: offset, behavior: 'instant'});
}

// Others select the text without scrolling, as window.find does. Reveal a
// selection below the clip, then bring its start into view.
async function revealSelection(range) {
  if (!folded.value) return;
  const selected = range.getBoundingClientRect();
  const visible = viewport.value.getBoundingClientRect();
  if (selected.top >= visible.top && selected.bottom <= visible.bottom) return;
  EventBus.$emit('cancelAutoScroll');
  reveal();
  await nextTick();
  const target = range.startContainer.nodeType === Node.ELEMENT_NODE ? range.startContainer : range.startContainer.parentElement;
  target.scrollIntoView({block: 'nearest'});
}
</script>

<template>
  <div class="body-preview" :class="{'body-preview--folded': folded}">
    <div ref="viewport" class="body-preview__viewport" @scroll="revealScrolledContent">
      <div ref="content" class="body-preview__content" tabindex="-1" @focusin="revealFocusedContent">
        <slot />
      </div>
    </div>
    <div v-if="folded && overflowing" class="body-preview__controls d-flex justify-center">
      <v-btn class="body-preview__show-more text-none" variant="text" :append-icon="mdiChevronDown" @click="showMore">
        {{ t('common.action.show_more') }}
      </v-btn>
    </div>
  </div>
</template>

<style>
.body-preview__content {
  display: flow-root;
}
.body-preview .body-preview__show-more {
  font-size: inherit;
  letter-spacing: inherit;
}
.body-preview--folded .body-preview__viewport {
  max-height: 13lh;
  overflow: hidden;
  mask-image: linear-gradient(to bottom, black calc(100% - 3lh), transparent);
  -webkit-mask-image: linear-gradient(to bottom, black calc(100% - 3lh), transparent);
}
</style>
