<script setup lang="js">
import { computed, nextTick, ref, watch } from 'vue';
import { merge } from 'lodash-es';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import AbilityService from '@/shared/services/ability_service';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  model: {
    type: Object,
    required: true
  },
  field: {
    type: String,
    required: true
  }
});

const { t } = useI18n();

const RICH_TEXT_IMAGE_MAX_HEIGHT = 600;
const RICH_TEXT_IMAGE_STYLE_CANDIDATE = /<img\b(?=[^>]*\bwidth\s*=)(?=[^>]*\bheight\s*=)(?![^>]*\baspect-ratio\s*:)/i;
const htmlContent = ref(null);

const canEdit = computed(() => AbilityService.canEdit(props.model));

const content = computed(() => {
  if (props.model.translationId) {
    return props.model.translation().fields[props.field];
  } else {
    return props.model[props.field];
  }
});

const format = computed(() => props.model[props.field + 'Format'] || 'none');

function formatDimension(value) {
  return value === Math.trunc(value) ? Math.trunc(value) : value.toFixed(2);
}

function applyImagePlaceholderStyles() {
  const root = htmlContent.value;
  if (!root || format.value !== 'html') { return; }

  root.querySelectorAll('img[width][height]').forEach(img => {
    if (img.style.aspectRatio) { return; }

    const widthAttr = img.getAttribute('width');
    const heightAttr = img.getAttribute('height');
    if (!/^\d+(\.\d+)?$/.test(widthAttr) || !/^\d+(\.\d+)?$/.test(heightAttr)) { return; }

    const width = Number(widthAttr);
    const height = Number(heightAttr);
    if (!width || !height) { return; }

    const displayWidth = Math.min(width, RICH_TEXT_IMAGE_MAX_HEIGHT * width / height);
    img.style.width = `min(${formatDimension(displayWidth)}px, 100%)`;
    img.style.height = 'auto';
    img.style.aspectRatio = `${widthAttr} / ${heightAttr}`;
  });
}

watch([content, format], () => {
  if (format.value !== 'html' || !content.value?.match?.(RICH_TEXT_IMAGE_STYLE_CANDIDATE)) { return; }

  nextTick(applyImagePlaceholderStyles);
}, { immediate: true });

function onClick(e) {
  const target = e.target;
  if (
    target?.getAttribute?.('data-type') === 'taskItem' &&
    e.offsetX < target.offsetLeft &&
    !target.classList.contains('task-item-busy')
  ) {
    const mentioned = target.querySelectorAll(
      'span[data-mention-id="' + Session.user().username + '"]'
    ).length;

    if (canEdit.value || mentioned) {
      target.classList.add('task-item-busy');
      const uid = target.getAttribute('data-uid');
      const checked = target.getAttribute('data-checked') === 'true';
      const params = merge(props.model.namedId(), {
        uid,
        done: (!checked && 'true') || 'false'
      });
      Records.remote.post('tasks/update_done', params).finally(() => {
        if (!checked) {
          Flash.success('tasks.task_updated_done');
        } else {
          Flash.success('tasks.task_updated_not_done');
        }
        target.classList.remove('task-item-busy');
      });
    } else {
      alert(t('tasks.permission_denied'));
    }
  }
}
</script>

<template lang="pug">
div.lmo-markdown-wrapper(@click="onClick")
  div(v-if="format == 'md'" v-marked='content')
  div(v-if="format == 'html'" ref="htmlContent" v-html='content')
  span(v-if="format == 'none'") Format none. Use plain-text instead.
</template>

<style lang="sass">
.lmo-markdown-wrapper
  a
    color: rgb(var(--v-theme-anchor))

.v-theme--dark
  .lmo-markdown-wrapper
    color: rgba(255,255,255,1)
    hr
      border-bottom: 2px solid rgba(255, 255, 255, 0.5)

    blockquote
      background-color: rgba(0,0,0,0.3)
      border-left: 4px solid #000

.editor
  .lmo-markdown-wrapper
    ul[data-type="taskList"]
      li::before
        content: none
        margin-right: 8px

      li[data-checked="true"]
        label::before
          content: none

      li[data-checked="true"]::before
        content: none

.lmo-markdown-wrapper
  color: rgba(0, 0, 0, 0.88)

  audio,video
    display: block
    margin-bottom: 8px

  span[style^="color"]
    color: inherit !important

  span[style^="background"], td[style^="background"], p[style^="background"]
    background: inherit !important

  a
    text-decoration: underline

  p
    margin-bottom: 0.75rem

  p:empty:first-child
    height: 0rem
    margin-bottom: 0

  p:empty
    height: 1rem

  p:last-child:empty
    display: none

  p:last-child
    margin-bottom: 0.25rem

  *[data-text-align="left"]
    text-align: left !important
  *[data-text-align="center"]
    text-align: center !important
  *[data-text-align="right"]
    text-align: right !important
  *[data-text-align="justify"]
    text-align: justify !important

  mark
    background-color: rgba(var(--v-theme-primary), 0.2)
    color: #000
    padding: 0.2em 0.3em

  mark[data-color="red"]
    background-color: #ef5350
  mark[data-color="pink"]
    background-color: #f48fb1
  mark[data-color="purple"]
    background-color: #ce93d8
  mark[data-color="blue"]
    background-color: #90caf9
  mark[data-color="green"]
    background-color: #a5d6a7
  mark[data-color="yellow"]
    background-color: #fff59d
  mark[data-color="orange"]
    background-color: #ffcc80
  mark[data-color="brown"]
    background-color: #bcaaa4
  mark[data-color="grey"]
    background-color: #e0e0e0

  .cursor
    font-size: 0.8rem
    font-weight: normal
    line-height: 20px
    letter-spacing: normal

  span[data-mention-id]
    color: rgb(var(--v-theme-anchor))

  blockquote, pre
    margin: 0.5rem 0

  h1, h2, h3
    margin-top: 1.5rem
    margin-bottom: 0.75rem

  h1:first-child, h2:first-child, h3:first-child
    margin-top: 0

  h1
    font-size: 1.75rem
    font-weight: 500
    letter-spacing: -0.015625rem

  h2
    font-size: 1.25rem
    font-weight: 500
    letter-spacing: normal

  h3
    font-size: 1rem
    font-weight: 700
    letter-spacing: normal

  strong
    font-weight: 700

  hr
    border: 0
    border-bottom: 2px solid rgba(0,0,0,0.1)
    margin: 16px 0

  overflow-wrap: break-word
  word-wrap: break-word
  word-break: break-word
  overflow: auto

  img
    max-width: 100%
    height: auto
    max-height: 600px

  ol, ul
    padding-left: 24px
    margin-bottom: .75rem

  ul
    list-style: disc

  ul[data-type="taskList"]
    list-style: none
    padding: 0

    li
      display: flex
      align-items: center
      justify-content: flex-start

      .v-selection-control
        flex-grow: 0

      input[type="checkbox"]
        margin-right: 8px

      p
        margin: 0

    li[data-due-on]:not([data-due-on=""])::after
      font-size: 10px
      color: #fff
      content: " 📅 " attr(data-due-on) ""
      border-radius: 8px
      background-color: rgb(var(--v-theme-primary))
      margin-left: 8px
      padding: 2px 8px
      height: 16px
      display: flex
      align-items: center
      // border: 1px solid rgb(var(--v-theme-primary))

    li::before
      content: ""
      display: inline-block
      vertical-align: bottom
      width: 1rem
      height: 1rem
      border-radius: 30%
      border-style: solid
      border-width: 0.1rem
      line-height: 100%
      margin-right: 8px
      border-color: rgba(var(--v-theme-on-surface), 0.2)
      min-width: 15px

    li[data-checked="true"]::before
      display: inline-block
      vertical-align: middle
      position: relative
      content: "✓"
      color: white
      text-align: center
      vertical-align: middle
      background-color: rgb(var(--v-theme-primary))
      border-color: rgb(var(--v-theme-primary))

    li:hover:before
      cursor: pointer
      border-color: rgba(var(--v-theme-primary), 0.4)

    li.task-item-busy::before
      background-color: rgba(var(--v-theme-primary), 0.4)
      border-color: rgba(var(--v-theme-primary), 0.4)
      // background-color: none !important

  ol
    list-style: decimal

  li p
    margin-bottom: 8px

  pre
    overflow-x: auto
    font-family: 'Roboto mono', monospace, monospace
    white-space: pre-wrap
    font-size: 0.88rem;
    margin: 1rem 0;

  pre code
    display: block

  p code
    display: inline-block
    background: rgba(0, 0, 0, .1)

  blockquote
    font-style: italic
    border-left: 4px solid rgba(0,0,0,.1)
    padding-left: .8rem
    padding: .5rem 0 0.5rem 0.8rem
    background-color: rgba(0,0,0,0.05)

  table
    table-layout: fixed
    width: 100%
    margin-bottom: 12px
    border-collapse: collapse

  table td
    padding: 4px 4px
    border: 1px solid #ddd

  thead td
    font-weight: bold

  table table
    margin: 0 !important
    border: 0 !important

  td td
    padding: 0 !important

  td td td
    border: 0 !important

  table
    p
      margin-bottom: 0

    p:last-child
      margin-bottom: 0

</style>
