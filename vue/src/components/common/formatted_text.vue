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

// Chrome serializes a selection that starts or ends inside a mention as a
// style-only span, dropping the data-mention-id needed to recreate the node.
// Expand mention boundary selections to the whole atomic mention and write the
// selected HTML ourselves so pasting it into a Loomio editor preserves the ID.
function onCopy(event) {
  const root = event.currentTarget;
  const selection = window.getSelection();
  if (!event.clipboardData || !selection?.rangeCount || selection.isCollapsed) { return; }

  const range = selection.getRangeAt(0).cloneRange();
  const closestMention = node => {
    const element = node.nodeType === Node.ELEMENT_NODE ? node : node.parentElement;
    const mention = element?.closest('span[data-mention-id]');
    return mention && root.contains(mention) ? mention : null;
  };
  const mentionStart = closestMention(range.startContainer);
  const mentionEnd = closestMention(range.endContainer);
  if (!mentionStart && !mentionEnd) { return; }

  if (mentionStart) { range.setStartBefore(mentionStart); }
  if (mentionEnd) { range.setEndAfter(mentionEnd); }

  const container = document.createElement('div');
  container.appendChild(range.cloneContents());
  event.clipboardData.setData('text/html', container.innerHTML);
  event.clipboardData.setData('text/plain', range.toString());
  event.preventDefault();
}
</script>

<template lang="pug">
div.lmo-markdown-wrapper(@click="onClick" @copy="onCopy")
  div(v-if="format == 'md'" v-marked='content')
  div(v-if="format == 'html'" ref="htmlContent" v-html='content')
  span(v-if="format == 'none'") Format none. Use plain-text instead.
</template>

<style>
@charset "UTF-8";
.lmo-markdown-wrapper a {
  color: rgb(var(--v-theme-anchor));
}

.v-theme--dark .lmo-markdown-wrapper {
  color: rgb(255, 255, 255);
}
.v-theme--dark .lmo-markdown-wrapper hr {
  border-bottom: 2px solid rgba(255, 255, 255, 0.5);
}

.editor .lmo-markdown-wrapper ul[data-type=taskList] li::before {
  content: none;
  margin-right: 8px;
}
.editor .lmo-markdown-wrapper ul[data-type=taskList] li[data-checked=true] label::before {
  content: none;
}
.editor .lmo-markdown-wrapper ul[data-type=taskList] li[data-checked=true]::before {
  content: none;
}

.lmo-markdown-wrapper audio, .lmo-markdown-wrapper video {
  display: block;
  margin-bottom: 8px;
}
.lmo-markdown-wrapper span[style^=color] {
  color: inherit !important;
}
.lmo-markdown-wrapper span[style^=background], .lmo-markdown-wrapper td[style^=background], .lmo-markdown-wrapper p[style^=background] {
  background: inherit !important;
}
.lmo-markdown-wrapper a {
  text-decoration: underline;
}
.lmo-markdown-wrapper p {
  margin-bottom: 0.75rem;
}
.lmo-markdown-wrapper p:empty:first-child {
  height: 0rem;
  margin-bottom: 0;
}
.lmo-markdown-wrapper p:empty {
  height: 1rem;
}
.lmo-markdown-wrapper p:last-child:empty {
  display: none;
}
.lmo-markdown-wrapper p:last-child {
  margin-bottom: 0.25rem;
}
.lmo-markdown-wrapper *[data-text-align=left] {
  text-align: left !important;
}
.lmo-markdown-wrapper *[data-text-align=center] {
  text-align: center !important;
}
.lmo-markdown-wrapper *[data-text-align=right] {
  text-align: right !important;
}
.lmo-markdown-wrapper *[data-text-align=justify] {
  text-align: justify !important;
}
.lmo-markdown-wrapper mark {
  background-color: rgba(var(--v-theme-primary), 0.2);
  color: #000;
  padding: 0.2em 0.3em;
}
.lmo-markdown-wrapper mark[data-color=red] {
  background-color: #ef5350;
}
.lmo-markdown-wrapper mark[data-color=pink] {
  background-color: #f48fb1;
}
.lmo-markdown-wrapper mark[data-color=purple] {
  background-color: #ce93d8;
}
.lmo-markdown-wrapper mark[data-color=blue] {
  background-color: #90caf9;
}
.lmo-markdown-wrapper mark[data-color=green] {
  background-color: #a5d6a7;
}
.lmo-markdown-wrapper mark[data-color=yellow] {
  background-color: #fff59d;
}
.lmo-markdown-wrapper mark[data-color=orange] {
  background-color: #ffcc80;
}
.lmo-markdown-wrapper mark[data-color=brown] {
  background-color: #bcaaa4;
}
.lmo-markdown-wrapper mark[data-color=grey] {
  background-color: #e0e0e0;
}
.lmo-markdown-wrapper .cursor {
  font-size: 0.8rem;
  font-weight: normal;
  line-height: 20px;
  letter-spacing: normal;
}
.lmo-markdown-wrapper span[data-mention-id] {
  background-color: rgba(var(--v-theme-anchor), 0.1);
  border-radius: 0.3em;
  color: rgb(var(--v-theme-anchor));
  padding: 0.05em 0.2em;
}
.lmo-markdown-wrapper blockquote, .lmo-markdown-wrapper pre {
  margin: 0.5rem 0;
}
.lmo-markdown-wrapper h1, .lmo-markdown-wrapper h2, .lmo-markdown-wrapper h3 {
  margin-top: 1.5rem;
  margin-bottom: 0.75rem;
}
.lmo-markdown-wrapper h1:first-child, .lmo-markdown-wrapper h2:first-child, .lmo-markdown-wrapper h3:first-child {
  margin-top: 0;
}
.lmo-markdown-wrapper h1 {
  font-size: 1.75rem;
  font-weight: 500;
  letter-spacing: -0.015625rem;
}
.lmo-markdown-wrapper h2 {
  font-size: 1.25rem;
  font-weight: 500;
  letter-spacing: normal;
}
.lmo-markdown-wrapper h3 {
  font-size: 1rem;
  font-weight: 700;
  letter-spacing: normal;
}
.lmo-markdown-wrapper strong {
  font-weight: 700;
}
.lmo-markdown-wrapper hr {
  border: 0;
  border-bottom: 2px solid rgba(0, 0, 0, 0.1);
  margin: 16px 0;
}
.lmo-markdown-wrapper {
  overflow-wrap: break-word;
  word-wrap: break-word;
  word-break: break-word;
  overflow: auto;
}
.lmo-markdown-wrapper img {
  width: auto;
  max-width: 100%;
  height: auto;
  max-height: 600px;
}
.lmo-markdown-wrapper ol, .lmo-markdown-wrapper ul {
  padding-left: 24px;
  margin-bottom: 0.75rem;
}
.lmo-markdown-wrapper ul {
  list-style: disc;
}
.lmo-markdown-wrapper ul[data-type=taskList] {
  list-style: none;
  padding: 0;
}
.lmo-markdown-wrapper ul[data-type=taskList] li {
  display: flex;
  align-items: center;
  justify-content: flex-start;
}
.lmo-markdown-wrapper ul[data-type=taskList] li .v-selection-control {
  flex-grow: 0;
}
.lmo-markdown-wrapper ul[data-type=taskList] li input[type=checkbox] {
  margin-right: 8px;
}
.lmo-markdown-wrapper ul[data-type=taskList] li p {
  margin: 0;
}
.lmo-markdown-wrapper ul[data-type=taskList] li[data-due-on]:not([data-due-on=""])::after {
  font-size: 10px;
  color: #fff;
  content: " 📅 " attr(data-due-on) "";
  border-radius: 8px;
  background-color: rgb(var(--v-theme-primary));
  margin-left: 8px;
  padding: 2px 8px;
  height: 16px;
  display: flex;
  align-items: center;
}
.lmo-markdown-wrapper ul[data-type=taskList] li::before {
  content: "";
  display: inline-block;
  vertical-align: bottom;
  width: 1rem;
  height: 1rem;
  border-radius: 30%;
  border-style: solid;
  border-width: 0.1rem;
  line-height: 100%;
  margin-right: 8px;
  border-color: rgba(var(--v-theme-on-surface), 0.2);
  min-width: 15px;
}
.lmo-markdown-wrapper ul[data-type=taskList] li[data-checked=true]::before {
  display: inline-block;
  vertical-align: middle;
  position: relative;
  content: "✓";
  color: white;
  text-align: center;
  vertical-align: middle;
  background-color: rgb(var(--v-theme-primary));
  border-color: rgb(var(--v-theme-primary));
}
.lmo-markdown-wrapper ul[data-type=taskList] li:hover:before {
  cursor: pointer;
  border-color: rgba(var(--v-theme-primary), 0.4);
}
.lmo-markdown-wrapper ul[data-type=taskList] li.task-item-busy::before {
  background-color: rgba(var(--v-theme-primary), 0.4);
  border-color: rgba(var(--v-theme-primary), 0.4);
}
.lmo-markdown-wrapper ol {
  list-style: decimal;
}
.lmo-markdown-wrapper li p {
  margin-bottom: 8px;
}
.lmo-markdown-wrapper pre {
  overflow-x: auto;
  font-family: "Roboto mono", monospace, monospace;
  white-space: pre-wrap;
  font-size: 0.88rem;
  margin: 1rem 0;
}
.lmo-markdown-wrapper pre code {
  display: block;
}
.lmo-markdown-wrapper p code {
  display: inline-block;
  background: rgba(0, 0, 0, 0.1);
}
.lmo-markdown-wrapper blockquote {
  position: relative;
  margin: 1rem 0;
  padding: 0.5rem 0 0.5rem 2.5rem;
  background: transparent;
  font-style: normal;
}
.lmo-markdown-wrapper blockquote::before {
  content: "";
  position: absolute;
  inset-inline-start: 0;
  top: 0.25rem;
  width: 2rem;
  height: 2rem;
  background-color: rgba(var(--v-theme-on-surface), var(--v-medium-emphasis-opacity));
  -webkit-mask-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M10,7L8,11H11V17H5V11L7,7H10M18,7L16,11H19V17H13V11L15,7H18Z'/%3E%3C/svg%3E");
  mask-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M10,7L8,11H11V17H5V11L7,7H10M18,7L16,11H19V17H13V11L15,7H18Z'/%3E%3C/svg%3E");
  -webkit-mask-size: contain;
  mask-size: contain;
  -webkit-mask-repeat: no-repeat;
  mask-repeat: no-repeat;
}
.lmo-markdown-wrapper table {
  table-layout: fixed;
  width: 100%;
  margin-bottom: 12px;
  border-collapse: collapse;
}
.lmo-markdown-wrapper table td {
  padding: 4px 4px;
  border: 1px solid #ddd;
}
.lmo-markdown-wrapper thead td {
  font-weight: bold;
}
.lmo-markdown-wrapper table table {
  margin: 0 !important;
  border: 0 !important;
}
.lmo-markdown-wrapper td td {
  padding: 0 !important;
}
.lmo-markdown-wrapper td td td {
  border: 0 !important;
}
.lmo-markdown-wrapper table p {
  margin-bottom: 0;
}
.lmo-markdown-wrapper table p:last-child {
  margin-bottom: 0;
}
</style>
