<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AppConfig from '@/shared/services/app_config';
import FileUploader from '@/shared/services/file_uploader';
import FilesList from './files_list.vue';
import EventBus from '@/shared/services/event_bus';
import I18n from '@/i18n';
import { convertToMd } from '@/shared/services/format_converter';

import Blockquote from '@tiptap/extension-blockquote';
import Bold from '@tiptap/extension-bold';
import BulletList from '@tiptap/extension-bullet-list';
import CodeBlock from '@tiptap/extension-code-block';
import Code from '@tiptap/extension-code';
import Document from '@tiptap/extension-document';
import Dropcursor from '@tiptap/extension-dropcursor';
import GapCursor from '@tiptap/extension-gapcursor';
import HardBreak from '@tiptap/extension-hard-break';
import Heading from '@tiptap/extension-heading';
import History from '@tiptap/extension-history';
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

import { Editor, EditorContent, VueRenderer } from '@tiptap/vue-2';

import {getEmbedLink} from '@/shared/helpers/embed_link';

import { CommonMentioning, HtmlMentioning, MentionPluginConfig } from './mentioning';
import SuggestionList from './suggestion_list';
import Attaching from './attaching';
import {compact, uniq, throttle, difference, reject, uniqBy} from 'lodash-es';
import TextHighlightBtn from './text_highlight_btn';
import TextAlignBtn from './text_align_btn';
import { TextAlign } from './extension_text_align';
import { Highlight } from './extension_highlight';

const isValidHttpUrl = function(string) {
  let url = undefined;
  try {
    url = new URL(string);
  } catch (_) {
    return false;
  }
  return (url.protocol === 'http:') || (url.protocol === 'https:');
};

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
      closeEmojiMenu: false,
      linkUrl: "",
      iframeUrl: "",
      linkDialogIsOpen: false,
      iframeDialogIsOpen: false,
      fetchedUrls: []
    };
  },

  computed: {
    format() {
      return this.model[`${this.field}Format`];
    },

    reasonTooLong() { 
      return this.editor.getCharacterCount() >= this.maxLength;
    }
  },

  mounted() {
    EventBus.$on('focusEditor', focusId => { 
      if (this.focusId === focusId) { return this.editor.commands.focus(); }
    });

    this.expanded = Session.user().experiences['html-editor.expanded'];
    this.model.beforeSaves.push( () => this.updateModel() );
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
        CustomImage.configure({attachFile: this.attachFile, attachImageFile: this.attachImageFile}),
        Video,
        Audio,
        Document,
        Dropcursor,
        GapCursor,
        HardBreak,
        Heading,
        Highlight.configure({ multicolor: true }),
        History,
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
      content: this.model[this.field],
      onUpdate: () => {
        if (this.maxLength) { this.checkLength(); }
        if (this.model.isNew()) { this.scrapeLinkPreviews(); }
      },
      onCreate: () => {
        if (this.model.isNew() && (this.editor.getCharacterCount() > 0) && this.autofocus) { this.editor.commands.focus('end'); }
      }
    });
  },

  watch: {
    'shouldReset': 'reset'
  },

  methods: {
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
      this.model.saveDisabled = this.editor.getCharacterCount() > this.maxLength;
    },

    setCount(count) {
      this.count = count;
    },

    tiptapAddress() {
      if (this.model.isNew()) {
        return compact([AppConfig.theme.channels_uri, 'tiptap', this.model.constructor.singular, 'new', this.model.groupId, this.model.discussionId, this.model.parentId, Session.user().secretToken]).join('/');
      } else {
        return [AppConfig.theme.channels_uri, 'tiptap', this.model.constructor.singular, this.model.id, (this.model.secretToken || Session.user().secretToken)].join('/');
      }
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
      this.resetFiles();
      this.model.beforeSave = () => this.updateModel();
    },

    convertToMd() {
      if (confirm(I18n.t('formatting.markdown_confirm'))) {
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
      this.closeEmojiMenu = false;
    },

    updateModel() {
      if (this.format !== 'html') { return; }
      this.model[this.field] = this.editor.getHTML();
      this.updateFiles();
    },

    removeLinkPreview(url) {
      this.model.linkPreviews = reject(this.model.linkPreviews, p => p.url === url);
    },

    scrapeLinkPreviews: throttle(function() {
      const parser = new DOMParser();
      const doc = parser.parseFromString(this.editor.getHTML(), 'text/html');
      this.fetchLinkPreviews(difference((Array.from(doc.querySelectorAll('a')).map(el => el.href)), this.fetchedUrls));
    }
    ,
      500
    ,
      {leading: false}),

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
  // @socket.close() if @socket

</script>

<template lang="pug">
div
  //- template(v-if="!editor || loading")
  //-   | Connecting to socket server …
  .editor(v-if="editor")
    editor-content.html-editor__textarea(ref="editor", :editor='editor').lmo-markdown-wrapper
    v-sheet.menubar
      div
        v-layout(align-center v-if="editor.isActive('table')")
          v-btn(icon @click="editor.chain().deleteTable().focus().run()", :title="$t('formatting.remove_table')")
            common-icon(small name="mdi-table-remove")
          v-btn(icon @click="editor.chain().addColumnBefore().focus().run()", :title="$t('formatting.add_column_before')")
            common-icon(small name="mdi-table-column-plus-before")
          v-btn(icon @click="editor.chain().addColumnAfter().focus().run()", :title="$t('formatting.add_column_after')")
            common-icon(small name="mdi-table-column-plus-after")
          v-btn(icon @click="editor.chain().deleteColumn().focus().run()", :title="$t('formatting.remove_column')")
            common-icon(small name="mdi-table-column-remove")
          v-btn(icon @click="editor.chain().addRowBefore().focus().run()", :title="$t('formatting.add_row_before')")
            common-icon(small name="mdi-table-row-plus-before")
          v-btn(icon @click="editor.chain().addRowAfter().focus().run()", :title="$t('formatting.add_row_after')")
            common-icon(small name="mdi-table-row-plus-after")
          v-btn(icon @click="editor.chain().deleteRow().focus().run()", :title="$t('formatting.remove_row')")
            common-icon(small name="mdi-table-row-remove")
          v-btn(icon @click="editor.chain().mergeOrSplit().focus().run()", :title="$t('formatting.merge_selected')")
            common-icon(small name="mdi-table-merge-cells")

        .d-flex.py-2.justify-space-between.flex-wrap.align-center(align-center)
          section.d-flex.flex-wrap.formatting-tools(:aria-label="$t('formatting.formatting_tools')")
            v-menu(:close-on-content-click="false" v-model="closeEmojiMenu")
              template(v-slot:activator="{on, attrs}")
                v-btn.emoji-picker__toggle(:small="expanded" v-on="on" v-bind="attrs" icon :title="$t('formatting.insert_emoji')")
                  common-icon(small name="mdi-emoticon-outline")
              emoji-picker(:insert="emojiPicked")

            v-btn(:small="expanded" icon @click='$refs.filesField.click()' :title="$t('formatting.attach')")
              common-icon(small name="mdi-paperclip")

            v-btn(:small="expanded" icon @click='$refs.imagesField.click()' :title="$t('formatting.insert_image')")
              common-icon(small name="mdi-image")

            v-btn(:small="expanded" icon @click='openRecordAudioModal' :title="$t('record_modal.record_audio')")
              common-icon(small name="mdi-microphone")

            v-btn(:small="expanded" icon @click='openRecordVideoModal' :title="$t('record_modal.record_video')")
              common-icon(small name="mdi-video")

            //- link
            v-menu(:close-on-content-click="!selectedText()", v-model="linkDialogIsOpen", min-width="320px")
              template(v-slot:activator="{on, attrs}")
                template(v-if="editor.isActive('link')")
                  v-btn(:small="expanded" icon @click="editor.chain().toggleLink().focus().run()", outlined :title="$t('formatting.link')")
                    common-icon(small name="mdi-link-variant")
                template(v-else)
                  v-btn(:small="expanded" icon v-on="on" v-bind="attrs", :title="$t('formatting.link')")
                    common-icon(small name="mdi-link-variant")
              v-card
                template(v-if="selectedText()")
                  v-card-title.title(v-t="'text_editor.insert_link'")
                  v-card-text
                    v-text-field(type="url" label="https://www.example.com" v-model="linkUrl" autofocus ref="focus" v-on:keyup.enter="setLinkUrl()")
                  v-card-actions
                    v-spacer
                    v-btn(small color="primary" @click="setLinkUrl()" v-t="'common.action.apply'")
                template(v-else)
                  v-card-title(v-t="'text_editor.select_text_to_link'")


            template(v-if="expanded")
              //- v-btn(icon @click='editor.chain().focus().setParagraph().run()' :outlined="editor.isActive('paragraph')" :title="$t('formatting.paragraph')")
              //-   common-icon(small name="mdi-format-pilcrow")
              template(v-for="i in [1,2,3]")
                v-btn(small icon @click='editor.chain().focus().toggleHeading({ level: i }).run()', :outlined="editor.isActive('heading', { level: i })", :title="$t('formatting.heading'+i)")
                  common-icon(small :name="'mdi-format-header-'+i")

            //- bold
            v-btn(small icon v-if="expanded", @click='editor.chain().toggleBold().focus().run()', :outlined="editor.isActive('bold')", :title="$t('formatting.bold')")
              common-icon(small name="mdi-format-bold")

            //- italic
            v-btn(small icon v-if="expanded" @click='editor.chain().toggleItalic().focus().run()', :outlined="editor.isActive('italic')", :title="$t('formatting.italicize')")
              common-icon(small name="mdi-format-italic")
            //-
            //- //- strikethrough
            v-btn(small icon v-if="expanded" @click='editor.chain().toggleStrike().focus().run()', :outlined="editor.isActive('strike')",  :title="$t('formatting.strikethrough')")
              common-icon(small name="mdi-format-strikethrough")
            //- underline
            //- v-btn(icon v-if="expanded" @click='editor.chain().toggleUnderline().focus().run()' :outlined="editor.isActive('underline')",  :title="$t('formatting.underline')")
            //-   common-icon(small name="mdi-format-underline")
            //-

            v-btn(small icon v-if="expanded" @click='editor.chain().toggleBulletList().focus().run()', :outlined="editor.isActive('bulletList')", :title="$t('formatting.bullet_list')")
              common-icon(small name="mdi-format-list-bulleted")
            v-btn(small icon v-if="expanded" @click='editor.chain().toggleOrderedList().focus().run()', :outlined="editor.isActive('orderedList')",  :title="$t('formatting.number_list')")
              common-icon(small name="mdi-format-list-numbered")
            v-btn(small icon v-if="expanded" @click='editor.chain().toggleTaskList().focus().run()', :outlined="editor.isActive('taskList')",  :title="$t('formatting.task_list')")
              common-icon(small name="mdi-checkbox-marked-outline")

            text-highlight-btn(v-if="expanded", :editor="editor")
            text-align-btn(v-if="expanded", :editor="editor")

            //- extra text marks
            template(v-if="expanded")
              //- strikethrough
              v-menu(small :close-on-content-click="false" v-model="iframeDialogIsOpen" min-width="320px")
                template(v-slot:activator="{on}")
                  v-btn(small icon v-on="on", :title="$t('formatting.embed')")
                    common-icon(small name="mdi-youtube")
                v-card
                  v-card-title.title(v-t="'text_editor.insert_embedded_url'")
                  v-card-text
                    v-text-field(type="url" label="e.g. https://www.youtube.com/watch?v=Zlzuqsunpxc" v-model="iframeUrl" ref="focus" autofocus v-on:keyup.enter="setIframeUrl()")
                  v-card-actions
                    v-spacer
                    v-btn(small color="primary" @click="setIframeUrl()" v-t="'common.action.apply'")
              //- blockquote
              v-btn(small icon @click='editor.chain().toggleBlockquote().focus().run()', :outlined="editor.isActive('blockquote')", :title="$t('formatting.blockquote')")
                common-icon(small name="mdi-format-quote-close")
              //- //- code block
              v-btn(small icon @click='editor.chain().toggleCodeBlock().focus().run()', :outlined="editor.isActive('codeBlock')", :title="$t('formatting.code_block')")
                common-icon(small name="mdi-code-braces")
              //- embded
              v-btn(small icon @click='editor.chain().setHorizontalRule().focus().run()', :title="$t('formatting.divider')")
                common-icon(small name="mdi-minus")
              //- table
              v-btn(small icon @click='editor.chain().insertTable({rows: 3, cols: 3, withHeaderRow: false }).focus().run()', :title="$t('formatting.add_table')", :outlined="editor.isActive('table')")
                common-icon(small name="mdi-table")
              //- markdown (save experience)
              v-btn(small icon @click="convertToMd", :title="$t('formatting.edit_markdown')")
                common-icon.e2e-markdown-btn(small name="mdi-language-markdown-outline")

            v-btn.html-editor__expand(v-if="!expanded" icon @click="toggleExpanded", :title="$t('formatting.expand')")
              common-icon(small name="mdi-chevron-right")

            v-btn.html-editor__expand(small v-if="expanded" icon @click="toggleExpanded", :title="$t('formatting.collapse')")
              common-icon(small name="mdi-chevron-left")

          //- save button?
          v-spacer
          slot(v-if="!expanded" name="actions")
          .text-right(dense v-if="maxLength", :class="{'red--text': reasonTooLong, 'text--secondary': !reasonTooLong}")
            span(:style="reasonTooLong ? 'font-weight: 700' : ''")
              | {{editor.getCharacterCount()}} / {{maxLength}}

    div.d-flex(v-if="expanded", name="actions")
      v-spacer
      slot(name="actions")

  link-previews(:model="model", :remove="removeLinkPreview")
  suggestion-list(:query="query", :loading="fetchingMentions", :mentionable="mentionable", :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex", @select-user="selectUser")
  files-list(:files="files", v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input.d-none(ref="filesField" type="file" name="files" multiple=true)

  form(style="display: block", @change="imageSelected")
    input.d-none(ref="imagesField", type="file", name="files", multiple=true)
</template>
<style lang="sass">

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

.theme--dark
  .ProseMirror p.is-editor-empty:first-child::before
    color: rgba(255,255,255,0.333)

.ProseMirror
  outline: none
  min-height: 64px

.theme--dark
  progress
    background-color: #333
    border-color: #444

progress
  width: 50%!important
  -webkit-appearance: none
  appearance: none
  background-color: #fff
  border: 1px solid #ccc
progress::-webkit-progress-bar
  background-color: #fff
  border: 1px solid #ccc
progress::-webkit-progress-value
  background-color: lightblue
  border: 0
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in
progress::-moz-progress-bar
  background-color: lightblue
  border: 0
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in

.menubar
  position: sticky
  bottom: 0

.menubar
  .drop-down-button
    width: 40px !important
  .menu-down-arrow
    margin-left: -10px
  // .v-btn--icon
  //   width: 32px
  //   height: 32px

  .v-btn.v-btn--icon
    min-width: 0
    margin-left: 0
    margin-right: 0
    max-width: 32px
    .v-icon
      font-size: 16px

.html-editor__textarea .ProseMirror
  border-bottom: 1px solid #999
  padding: 4px 0px
  margin: 4px 0px
  outline: none
  overflow-y: scroll
  overflow: visible

.html-editor__textarea .ProseMirror:focus
  border-bottom: 1px solid var(--v-primary-base)


// .lmo-textarea p.is-empty:first-child::before
//   content: attr(data-empty-text)
//   float: left
//   color: #aaa
//   pointer-events: none
//   height: 0
//
// .lmo-textarea p.is-empty
//   font-size: 16px
//   padding-bottom: 16px

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
    border: 1px solid var(--v-primary-base)
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
