<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AppConfig from '@/shared/services/app_config';
import FileUploader from '@/shared/services/file_uploader';
import FilesList from './files_list.vue';
import EventBus from '@/shared/services/event_bus';
import { I18n } from '@/i18n';
import { convertToMd } from '@/shared/services/format_converter';
import CharacterCount from '@tiptap/extension-character-count';
import Blockquote from '@tiptap/extension-blockquote';
import Bold from '@tiptap/extension-bold';
import BulletList from '@tiptap/extension-bullet-list';
import CodeBlock from '@tiptap/extension-code-block';
import Document from '@tiptap/extension-document';
import Dropcursor from '@tiptap/extension-dropcursor';
import GapCursor from '@tiptap/extension-gapcursor';
import HardBreak from '@tiptap/extension-hard-break';
import Heading from '@tiptap/extension-heading';
import HorizontalRule from '@tiptap/extension-horizontal-rule';
import Italic from '@tiptap/extension-italic';
import Link from '@tiptap/extension-link';
import ListItem from '@tiptap/extension-list-item';
import OrderedList from '@tiptap/extension-ordered-list';
import Paragraph from '@tiptap/extension-paragraph';
import Placeholder from '@tiptap/extension-placeholder';
import Strike from '@tiptap/extension-strike';
import TableCell from '@tiptap/extension-table-cell';
import TableHeader from '@tiptap/extension-table-header';
import TableRow from '@tiptap/extension-table-row';
import Table from '@tiptap/extension-table';
// import TaskList from '@tiptap/extension-task-list'
import {CustomTaskItem} from './extension_custom_task_item';
import {CustomTaskList} from './extension_custom_task_list';
import TextStyle from '@tiptap/extension-text-style';
// import TextAlign from '@tiptap/extension-text-align'
import Text from '@tiptap/extension-text';
import Underline from '@tiptap/extension-underline';
import {CustomMention} from './extension_mention';
import {CustomImage} from './extension_image';
import {Video} from './extension_image';
import {Audio} from './extension_image';
import {Iframe} from './extension_iframe';

import { Editor, EditorContent } from '@tiptap/vue-3';

import { getEmbedLink } from '@/shared/helpers/embed_link';

import { CommonMentioning, HtmlMentioning, MentionPluginConfig } from './mentioning';
import SuggestionList from './suggestion_list';
import Attaching from './attaching';
import { uniq, reject, uniqBy } from 'lodash-es';
import TextHighlightBtn from './text_highlight_btn';
import TextAlignBtn from './text_align_btn';
import { TextAlign } from './extension_text_align';
import { Highlight } from './extension_highlight';

import Collaboration from '@tiptap/extension-collaboration';
import CollaborationCursor from '@tiptap/extension-collaboration-cursor'
import { HocuspocusProvider } from '@hocuspocus/provider';
import { IndexeddbPersistence } from 'y-indexeddb';

const isValidHttpUrl = function(string) {
  let url = undefined;
  try {
    url = new URL(string);
  } catch (_) {
    return false;
  }
  return (url.protocol === 'http:') || (url.protocol === 'https:');
};

var provider = null;

export default
{
  mixins: [CommonMentioning, HtmlMentioning, Attaching],
  props: {
    focusId: String,
    model: Object,
    field: String,
    label: String,
    placeholder: String,
    maxLength: Number,
    shouldReset: Boolean,
    autofocus: Boolean
  },

  components: {
    EditorContent,
    TextAlignBtn,
    TextHighlightBtn,
    SuggestionList,
    FilesList
  },

  data() {
    return {
      loading: true,
      socket: null,
      count: 0,
      editor: null,
      expanded: false,
      linkUrl: "",
      iframeUrl: "",
      linkDialogIsOpen: false,
      iframeDialogIsOpen: false,
      fetchedUrls: [],
      btnProps: {
        size: 'small',
        density: 'comfortable',
        icon: true,
        variant: 'text'
      }
    };
  },

  mounted() {
    const docname = this.model.collabKey(this.field, (Session.user().id || AppConfig.channel_token));

    const onSync = function(provider) {
      if (this.editor) {
        if (!provider.document.getMap('config').get('initialContentLoaded')) {
          provider.document.getMap('config').set('initialContentLoaded', true)
          this.editor.commands.setContent(this.model[this.field]);
        } else if (this.editor.storage.characterCount.characters() == 0 && !this.model.attributeIsBlank(this.field)) {
          this.editor.commands.setContent(this.model[this.field]);
        }
      } else {
        setTimeout( () => onSync(provider) , 250);
      }
    }.bind(this);

    provider = new HocuspocusProvider({
      url: AppConfig.theme.hocuspocus_url,
      name: docname,
      token: (Session.user().id || 0) + "," + AppConfig.channel_token,
      onSynced: function() { onSync(provider); }.bind(this),
    });

    new IndexeddbPersistence(docname, provider.document);

    this.expanded = Session.user().experiences['html-editor.expanded'];
    this.model.beforeSaves.push(() => this.updateModel() );

    this.editor = new Editor({
      editorProps: {
        scrollThreshold: 100,
        scrollMargin: 100
      },
      autofocus: this.autofocus,
      extensions: [
        Blockquote,
        Bold,
        BulletList,
        CodeBlock,
        CharacterCount.configure({limit: this.maxLength}),
        CustomImage.configure({attachFile: this.attachFile, attachImageFile: this.attachImageFile}),
        Collaboration.configure({
          document: provider.document,
        }),
        CollaborationCursor.configure({
          provider: provider,
          user: {
            name: Session.user().name,
            color: '#f783ac',
            thumbUrl: Session.user().thumbUrl,
          },
          render: user => {
            const cursor = document.createElement('span')

            cursor.classList.add('collaboration-cursor__caret')

            const label = document.createElement('div')
            label.classList.add('collaboration-cursor__label')


            if (user.thumbUrl) {
              label.classList.add('collaboration-cursor__label-with-avatar')
              const avatarDiv = document.createElement('div')
              avatarDiv.classList.add('collaboration-cursor__avatar-div')
              const avatar = document.createElement('img')
              avatar.setAttribute('src', user.thumbUrl)
              avatar.classList.add('collaboration-cursor__avatar')
              avatarDiv.insertBefore(avatar, null)
              label.insertBefore(avatarDiv, null)
            }

            label.insertBefore(document.createTextNode(user.name), null)
            cursor.insertBefore(label, null)

            return cursor
          }
        }),
        Video,
        Audio,
        Document,
        Dropcursor,
        GapCursor,
        HardBreak,
        Heading,
        Highlight.configure({ multicolor: true }),
        HorizontalRule,
        Italic,
        Iframe,
        Link,
        ListItem,
        OrderedList,
        Paragraph,
        Placeholder.configure({placeholder: () => this.placeholder}),
        Strike,
        Text,
        Table,
        TableHeader,
        TableRow,
        TableCell,
        CustomTaskList,
        CustomTaskItem,
        CustomMention.configure(MentionPluginConfig.bind(this)()),
        TextStyle,
        TextAlign.configure({ types: ['heading', 'paragraph'] }),
        Underline
      ],
      onUpdate: () => {
        if (this.maxLength) { this.checkLength(); }
      },
      onCreate: () => {
        if (this.model.isNew() && (this.charCount() > 0) && this.autofocus) { this.editor.commands.focus('end'); }
      }
    });

    EventBus.$on('focusEditor', focusId => {
      if (this.focusId === focusId) { return this.editor.commands.focus(); }
    });

    EventBus.$on('resetDraft', (type, id, field, content) => {
      if (type == this.model.constructor.singular &&
          id == this.model.id &&
          field == this.field) {
        this.resetDraft(content);
      }
    });
  },

  computed: {
    format() {
      return this.model[`${this.field}Format`];
    },
  },

  watch: {
    'shouldReset': 'reset'
  },

  methods: {
    reasonTooLong() {
      return this.charCount() >= this.maxLength;
    },

    charCount() {
      return this.editor.storage.characterCount.characters()
    },

    resetDraft(content) {
      this.editor.commands.setContent(content);
    },

    openRecordVideoModal() {
      EventBus.$emit('openModal', {
        component: 'RecordVideoModal',
        props: {
          saveFn: this.mediaRecorded
        }
      }
      );
    },

    openRecordAudioModal() {
      EventBus.$emit('openModal', {
        component: 'RecordAudioModal',
        props: {
          saveFn: this.mediaRecorded
        }
      }
      );
    },

    checkLength() {
      this.model.saveDisabled = this.charCount() > this.maxLength;
    },

    setCount(count) {
      this.count = count;
    },

    selectedText() {
      const {
        state
      } = this.editor;
      const {
        selection
      } = this.editor.state;
      const { from, to } = selection;
      return state.doc.textBetween(from, to, ' ');
    },

    reset() {
      this.editor.chain().clearContent().run();
      provider.document.getMap('config').set('initialContentLoaded', false);
      this.resetFiles();
      this.model.beforeSaves.push(() => this.updateModel() );
    },

    convertToMd() {
      if (confirm(I18n.global.t('formatting.markdown_confirm'))) {
        this.updateModel();
        convertToMd(this.model, this.field);
        Records.users.saveExperience('html-editor.uses-markdown');
      }
    },

    toggleExpanded() {
      this.expanded = !this.expanded;
      Records.users.saveExperience('html-editor.expanded', this.expanded);
    },

    setLinkUrl() {
      if (this.linkUrl) {
        if (!this.linkUrl.includes("://")) { this.linkUrl = "http://".concat(this.linkUrl); }
        this.editor.chain().setLink({href: this.linkUrl}).focus().run();
        this.fetchLinkPreviews([this.linkUrl]);
        this.linkUrl = null;
      }
      this.linkDialogIsOpen = false;
    },

    setIframeUrl() {
      if (!isValidHttpUrl(this.iframeUrl)) { return; }
      this.editor.chain().setIframe({src: getEmbedLink(this.iframeUrl)}).focus().run();
      this.iframeUrl = null;
      this.iframeDialogIsOpen = false;
    },

    emojiPicked(shortcode, unicode) {
      this.editor.chain()
          .insertContent(unicode)
          .focus()
          .run();
    },

    updateModel() {
      if (this.format !== 'html') { return; }
      this.model[this.field] = this.editor.getHTML();
      this.updateFiles();
    },

    removeLinkPreview(url) {
      this.model.linkPreviews = reject(this.model.linkPreviews, p => p.url === url);
    },

    fetchLinkPreviews(urls) {
      if (urls.length) {
        this.fetchedUrls = uniq(this.fetchedUrls.concat(urls));
        Records.remote.post('link_previews', {urls, discussion_id: this.model.discussionId}).then(data => {
          this.model.linkPreviews = uniqBy(this.model.linkPreviews.concat(data.previews), 'url');
        });
      }
    }
  },

  beforeDestroy() {
    if (this.editor) { this.editor.destroy(); }
  }
};

</script>

<template lang="pug">
div.mb-2
  .v-input.v-input--density-default.editor(v-if="editor")
    .v-input-control
      .v-field.v-field--active.v-field--variant-filled
        .v-field__overlay

        .v-field__field(style="display: block")
          label.v-label.v-field-label.v-field-label--floating(v-if="label" aria-hidden="true")
            span {{label}}
          editor-content.html-editor__textarea.mx-4(:class="{'mt-6': label, 'mt-2': !label}" ref="editor" :editor='editor').lmo-markdown-wrapper
        .v-field__outline
    v-sheet.menubar.position-sticky.bottom-0
      .d-flex.align-center.pt-2(v-if="editor.isActive('table')")
        v-btn(v-bind="btnProps" @click="editor.chain().deleteTable().focus().run()" :title="$t('formatting.remove_table')")
          common-icon(name="mdi-table-remove")
        v-btn(v-bind="btnProps" @click="editor.chain().addColumnBefore().focus().run()" :title="$t('formatting.add_column_before')")
          common-icon(name="mdi-table-column-plus-before")
        v-btn(v-bind="btnProps" @click="editor.chain().addColumnAfter().focus().run()" :title="$t('formatting.add_column_after')")
          common-icon(name="mdi-table-column-plus-after")
        v-btn(v-bind="btnProps" @click="editor.chain().deleteColumn().focus().run()" :title="$t('formatting.remove_column')")
          common-icon(name="mdi-table-column-remove")
        v-btn(v-bind="btnProps" @click="editor.chain().addRowBefore().focus().run()" :title="$t('formatting.add_row_before')")
          common-icon(name="mdi-table-row-plus-before")
        v-btn(v-bind="btnProps" @click="editor.chain().addRowAfter().focus().run()" :title="$t('formatting.add_row_after')")
          common-icon(name="mdi-table-row-plus-after")
        v-btn(v-bind="btnProps" @click="editor.chain().deleteRow().focus().run()" :title="$t('formatting.remove_row')")
          common-icon(name="mdi-table-row-remove")
        v-btn(v-bind="btnProps" @click="editor.chain().mergeOrSplit().focus().run()" :title="$t('formatting.merge_selected')")
          common-icon(name="mdi-table-merge-cells")

      .d-flex.py-2.justify-space-between.flex-wrap.align-center(align-center)
        section.d-flex.flex-wrap.formatting-tools(:aria-label="$t('formatting.formatting_tools')")
          v-btn.emoji-picker__toggle(v-bind="btnProps" :title="$t('formatting.insert_emoji')")
            common-icon(name="mdi-emoticon-outline")
            v-menu(activator="parent")
              emoji-picker(:insert="emojiPicked")

          v-btn(v-bind="btnProps" @click='$refs.filesField.click()' :title="$t('formatting.attach')")
            common-icon(name="mdi-paperclip")

          v-btn(v-bind="btnProps" @click='$refs.imagesField.click()' :title="$t('formatting.insert_image')")
            common-icon(name="mdi-image")

          //- link
          template(v-if="editor.isActive('link')")
            v-btn(v-bind="btnProps" variant="tonal" @click="editor.chain().toggleLink().focus().run()" :title="$t('formatting.link')")
              common-icon(name="mdi-link-variant")

          template(v-else)
            v-btn(v-bind="btnProps" :title="$t('formatting.link')")
              common-icon(name="mdi-link-variant")
              v-menu(activator="parent" :close-on-content-click="!selectedText()" v-model="linkDialogIsOpen")
                template(v-if="selectedText()")
                  v-card(:min-width="320" :title="$t('text_editor.insert_link')")
                    v-card-text
                      v-text-field(variant="solo-filled" hide-details type="url" placeholder="https://www.example.com" v-model="linkUrl" autofocus ref="focus" v-on:keyup.enter="setLinkUrl()")
                    v-card-actions
                      v-spacer
                      v-btn(variant="tonal"  color="primary" @click="setLinkUrl()")
                        span(v-t="'common.action.apply'")
                template(v-else)
                  v-card(:title="$t('text_editor.select_text_to_link')")

          template(v-if="expanded")
            v-btn(v-bind="btnProps" @click='openRecordAudioModal' :title="$t('record_modal.record_audio')")
              common-icon(name="mdi-microphone")

            v-btn(v-bind="btnProps" @click='openRecordVideoModal' :title="$t('record_modal.record_video')")
              common-icon(name="mdi-video")

            template(v-for="i in [1,2,3]")
              v-btn(v-bind="btnProps" :variant="editor.isActive('heading', { level: i }) ? 'tonal' :'text' " @click='editor.chain().focus().toggleHeading({ level: i }).run()' :title="$t('formatting.heading'+i)")
                common-icon(:name="'mdi-format-header-'+i")

            v-btn(v-bind="btnProps" :variant="editor.isActive('bold') ? 'tonal' : 'text'" @click='editor.chain().toggleBold().focus().run()' :title="$t('formatting.bold')")
              common-icon(name="mdi-format-bold")

            v-btn(v-bind="btnProps" :variant="editor.isActive('italic') ? 'tonal' : 'text'" @click='editor.chain().toggleItalic().focus().run()' :title="$t('formatting.italicize')")
              common-icon(name="mdi-format-italic")

            v-btn(v-bind="btnProps" :variant="editor.isActive('strike') ? 'tonal' : 'text'" @click='editor.chain().toggleStrike().focus().run()' :title="$t('formatting.strikethrough')")
              common-icon(name="mdi-format-strikethrough")

            //- v-btn(icon variant="text" @click='editor.chain().toggleUnderline().focus().run()' :outlined="editor.isActive('underline')",  :title="$t('formatting.underline')")
            //-   common-icon(name="mdi-format-underline")
            v-btn(v-bind="btnProps" :variant="editor.isActive('bulletList') ? 'tonal' : 'text'" @click='editor.chain().toggleBulletList().focus().run()' :title="$t('formatting.bullet_list')")
              common-icon(name="mdi-format-list-bulleted")

            v-btn(v-bind="btnProps" :variant="editor.isActive('orderedList') ? 'tonal' : 'text'" @click='editor.chain().toggleOrderedList().focus().run()' :title="$t('formatting.number_list')")
              common-icon(name="mdi-format-list-numbered")

            v-btn(v-bind="btnProps" :variant="editor.isActive('taskList') ? 'tonal' : 'text'" @click='editor.chain().toggleTaskList().focus().run()' :title="$t('formatting.task_list')")
              common-icon(name="mdi-checkbox-marked-outline")

            text-highlight-btn(:editor="editor" :btnProps="btnProps")
            text-align-btn(:editor="editor" :btnProps="btnProps")

            //- strikethrough
            v-btn(v-bind="btnProps" :title="$t('formatting.embed')")
              common-icon(name="mdi-youtube")
              v-menu(activator="parent" :close-on-content-click="false" v-model="iframeDialogIsOpen" min-width="320px")
                template(v-slot:activator="{ props }")
                v-card(style="min-width: 365px")
                  v-card-title(v-t="'text_editor.insert_embedded_url'")
                  v-card-text
                    v-text-field(type="url" label="e.g. https://www.youtube.com/watch?v=Zlzuqsunpxc" v-model="iframeUrl" ref="focus" autofocus v-on:keyup.enter="setIframeUrl()")
                  v-card-actions
                    v-spacer
                    v-btn(color="primary" @click="setIframeUrl()" v-t="'common.action.apply'")

            //- blockquote
            v-btn(v-bind="btnProps" :variant="editor.isActive('blockquote') ? 'tonal' : 'text'" @click='editor.chain().toggleBlockquote().focus().run()' :title="$t('formatting.blockquote')")
              common-icon(name="mdi-format-quote-close")
            //- //- code block
            v-btn(v-bind="btnProps" :variant="editor.isActive('codeBlock') ? 'tonal' : 'text'" @click='editor.chain().toggleCodeBlock().focus().run()' :title="$t('formatting.code_block')")
              common-icon(name="mdi-code-braces")
            //- embded
            v-btn(v-bind="btnProps" @click='editor.chain().setHorizontalRule().focus().run()' :title="$t('formatting.divider')")
              common-icon(name="mdi-minus")
            //- table
            v-btn(v-bind="btnProps" :variant="editor.isActive('table') ? 'tonal' : 'text'" @click='editor.chain().insertTable({rows: 3, cols: 3, withHeaderRow: false }).focus().run()' :title="$t('formatting.add_table')")
              common-icon(name="mdi-table")
            //- markdown (save experience)
            v-btn(v-bind="btnProps" @click="convertToMd" :title="$t('formatting.edit_markdown')")
              common-icon.e2e-markdown-btn(size="x-small" name="mdi-language-markdown-outline")

            v-btn.html-editor__expand(v-bind="btnProps" @click="toggleExpanded" :title="$t('formatting.collapse')")
              common-icon(name="mdi-chevron-left")

          v-btn.html-editor__expand(v-if="!expanded" v-bind="btnProps" @click="toggleExpanded" :title="$t('formatting.expand')")
            common-icon(name="mdi-chevron-right")


        v-spacer
        slot(v-if="!expanded" name="actions")
        v-chip.text-right(
          :color="reasonTooLong() ? 'error' : null"
          density="compact"
          variant="tonal"
          v-if="maxLength"
        ) {{charCount()}} / {{maxLength}}

    div.d-flex(v-if="expanded" name="actions")
      v-spacer
      slot(name="actions")

  link-previews(:model="model" :remove="removeLinkPreview")
  suggestion-list(
    :query="query"
    :loading="fetchingMentions"
    :mentions="mentions"
    :positionStyles="suggestionListStyles"
    :navigatedUserIndex="navigatedUserIndex"
    @select-row="selectRow")
  files-list(:files="files", v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input.d-none(ref="filesField" type="file" name="files" multiple=true)

  form(style="display: block", @change="imageSelected")
    input.d-none(ref="imagesField", type="file", name="files", multiple=true)
</template>
<style lang="sass">

.collaboration-cursor__avatar-div
  width: 18px
  height: 18px
  margin-right: 4px

img.collaboration-cursor__avatar
  height: 100%
  width: 100%
  object-fit: cover
  border-radius: 100%

.collaboration-cursor__caret
  border-left: 1px solid #333
  margin-left: -1px
  margin-right: -1px
  pointer-events: none
  position: relative !important
  word-break: normal
  z-index: 100

.v-theme--dark, .v-theme--darkBlue
  .collaboration-cursor__caret
    border-left: 1px solid #ddd

  .collaboration-cursor__label
    color: #fff
    background-color: #3338
    border-color: #eee

.collaboration-cursor__label
  opacity: 0.75
  display: flex
  align-items: center
  border-radius: 16px
  border: 0px solid #333
  background-color: #ddd8
  color: #000
  font-size: 12px
  font-style: normal
  font-weight: 400
  left: -1px
  line-height: normal
  padding: 2px 6px
  position: absolute
  top: -1.4em
  user-select: none
  white-space: nowrap

.collaboration-cursor__label-with-avatar
  padding: 0 4px 0 0 !important

.ProseMirror-widget
  position: absolute
  width: 0.1px
  /*border-style: solid;*/

.bv-row
  padding-top: 20px

.ProseMirror [contenteditable="false"]
  white-space: normal

.ProseMirror [contenteditable="true"]
  white-space: pre-wrap

// .ProseMirror
//   > * + *
//     margin-top: 0.75em

/* Placeholder (at the top) */
.ProseMirror p.is-editor-empty:first-child::before
  content: attr(data-placeholder)
  float: left
  color: rgba(0,0,0,0.25)
  pointer-events: none
  height: 0

.v-theme--dark, .v-theme--darkBlue
  .ProseMirror p.is-editor-empty:first-child::before
    color: rgba(255,255,255,0.333)

.ProseMirror
  outline: none
  min-height: 64px

progress
  background-color: rgb(var(--v-theme-background)) !important;
  border: 1px solid rgba(var(--v-border-color), var(--v-disabled-opacity)) !important;
  width: 100%!important
  height: 16px;

progress::-moz-progress-bar
  border: 0
  background-color: rgb(var(--v-theme-primary)) !important;

progress::-webkit-progress-bar
  background-color: rgb(var(--v-theme-background)) !important;

progress::-webkit-progress-value
  background-color: rgb(var(--v-theme-primary)) !important;

.menubar
  position: sticky
  bottom: 0

//  .v-btn.v-btn--icon
//    min-width: 0
//    margin-left: 0
//    margin-right: 0
//    max-width: 32px
//    .v-icon
//      font-size: 16px

.html-editor__textarea .ProseMirror
  cursor: text
  padding: 4px 0px
  margin: 4px 0px
  outline: none
  overflow-y: scroll
  overflow: visible

ul[data-type="todo_list"]
  padding-left: 0

li[data-type="todo_item"]
  display: flex
  flex-direction: row

.todo-checkbox
  border: 1px solid #999
  height: 1.3em
  width: 1.3em
  box-sizing: border-box
  margin-right: 8px
  margin-top: 0px
  user-select: none
  border-radius: 0.2em
  background-color: transparent
  &:hover
    border: 1px solid rgb(var(--v-theme-primary))
    // background: #eee

.lmo-textarea .todo-checkbox
  cursor: pointer

.todo-content
  flex: 1
  > p:last-of-type
    margin-bottom: 0
  > ul[data-type="todo_list"]
    margin: .5rem 0
  p
    margin: 0

li[data-done="true"]
  > .todo-content
    > p
      text-decoration: line-through
  > .todo-checkbox::before
    position: relative
    top: -6px
    color: var(--v-accent-base)
    font-size: 1.5rem
    content: "✓"

li[data-done="false"]
  text-decoration: none

input[type="file"]
  display: none

// .html-editor__textarea, .formatted-text
.lmo-markdown-wrapper
  video
    position: relative
    width: 100%
    height: auto

  div[data-iframe-container], .iframe-container
    position: relative
    padding-bottom: 100/16*9%
    height: 0
    overflow: hidden
    width: 100%
    height: auto
    margin: 0 auto
    &.ProseMirror-selectednode
      outline: 3px solid #68CEF8
    iframe
      border: 0
      position: absolute
      top: 0
      left: 0
      width: 100%
      height: 100%
      outline: 2px solid #68CEF8

@media screen and (min-width: 960px)
  div[data-iframe-container], .iframe-container
    padding-bottom: 432px !important
    max-width: 768px

</style>
