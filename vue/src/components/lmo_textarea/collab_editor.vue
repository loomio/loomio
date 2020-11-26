<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import AppConfig from '@/shared/services/app_config'
import FileUploader from '@/shared/services/file_uploader'
import FilesList from './files_list.vue'
import EventBus from '@/shared/services/event_bus'
import I18n from '@/i18n'
import { convertToMd } from '@/shared/services/format_converter'

import { Editor, EditorContent, EditorMenuBar } from 'tiptap'

import { Blockquote, CodeBlock, HardBreak, HorizontalRule,
  OrderedList, BulletList, ListItem, Table, TableHeader, TableCell,
  TableRow, TodoList, Bold, Code, Italic, Link, Strike, Underline,
  History, Mention, Placeholder, TrailingNode } from 'tiptap-extensions'
import Collaboration from '@/shared/tiptap_extentions/collaboration.js'

import ForeColor from '@/shared/tiptap_extentions/fore_color'
import BackColor from '@/shared/tiptap_extentions/back_color'
import FormatClear from '@/shared/tiptap_extentions/format_clear'
import Align from '@/shared/tiptap_extentions/align'
import Alignment from '@/shared/tiptap_extentions/alignment'
import Paragraph from '@/shared/tiptap_extentions/paragraph'
import Heading from '@/shared/tiptap_extentions/heading'

import Iframe from './iframe'
import TodoItem from './todo_item'

import { insertText } from 'tiptap-commands'
import Image from '@/shared/tiptap_extentions/image.js'

import {getEmbedLink} from '@/shared/helpers/embed_link.coffee'

import { CommonMentioning, HtmlMentioning, MentionPluginConfig } from './mentioning.coffee'
import SuggestionList from './suggestion_list'
import Attaching from './attaching.coffee'
import {compact} from 'lodash'
import TextHighlightBtn from './text_highlight_btn'
import TextAlignBtn from './text_align_btn'

# import io from 'socket.io-client'

export default
  mixins: [CommonMentioning, HtmlMentioning, Attaching]
  props:
    model: Object
    field: String
    label: String
    placeholder: String
    maxLength: Number
    shouldReset: Boolean
    autofocus: Boolean

  components:
    EditorContent: EditorContent
    EditorMenuBar: EditorMenuBar
    FilesList: FilesList
    SuggestionList: SuggestionList
    TextHighlightBtn: TextHighlightBtn
    TextAlignBtn: TextAlignBtn

  data: ->
    loading: true
    socket: null
    count: 0
    editor: null
    expanded: null
    closeEmojiMenu: false
    linkUrl: ""
    iframeUrl: ""
    linkDialogIsOpen: false
    iframeDialogIsOpen: false

  computed:
    format: ->
      @model["#{@field}Format"]

  mounted: ->
    @expanded = Session.user().experiences['html-editor.expanded']
    @onInit({doc: null, version: 0})
    # @socket = io(@tiptapAddress())
    #   .on('init', (data) => @onInit(data))
    #   .on('update', (data) =>
    #     @editor.extensions.options.collaboration.update(data)
    #     @editor.extensions.options.collaboration.updateCursors(data)
    #   )
    #   .on('getCount', (count) => @setCount(count))
    #   .on('cursorupdate', (data) =>
    #     this.editor.extensions.options.collaboration.updateCursors(data)
    #   )

  watch:
    'shouldReset': 'reset'

  methods:
    onInit: ({doc, version}) ->
      @loading = false
      @editor.destroy() if @editor

      @editor = new Editor
        editorProps:
          scrollThreshold: 100
          scrollMargin: 100
        extensions: [
          new Link(),
          new Mention(MentionPluginConfig.bind(@)()),
          new Blockquote(),
          new BulletList(),
          new CodeBlock(),
          new HardBreak(),
          new Image({attachFile: @attachFile, attachImageFile: @attachImageFile}),
          new Heading({ levels: [1, 2, 3] }),
          new HorizontalRule(),
          new ListItem(),
          new OrderedList(),
          new TodoItem(),
          new TodoList(),
          new Table(),
          new TableHeader(),
          new TableCell(),
          new TableRow(),
          new Bold(),
          new Code(),
          new Italic(),
          new Strike(),
          new Underline(),
          new History(),
          new Iframe(),
          new ForeColor(),
          new BackColor(),
          new FormatClear(),
          new Align(),
          new Alignment(),
          new Paragraph(),
          new Placeholder({
            emptyClass: 'is-empty',
            emptyNodeText: @placeholder,
            showOnlyWhenEditable: true,
          }),
          # new Collaboration({
          #   socket: @socket,
          #   user: Session.user()
          #   version: version
          #   debounce: 250
          # })
        ]
        content: @model[@field] # doc
        onUpdate: @updateModel
        autoFocus: @autofocus

      # @editor.setContent(@model[@field]) if version == 0

      # setTimeout =>
      #   if @$refs.editor && @$refs.editor.$el
      #     @$refs.editor.$el.children[0].setAttribute("role", "textbox")
      #     @$refs.editor.$el.children[0].setAttribute("aria-label", @placeholder) if @placeholder

    setCount: (count) ->
      @count = count

    tiptapAddress: ->
      if @model.isNew()
        compact([AppConfig.theme.channels_uri, 'tiptap', @model.constructor.singular, 'new', @model.groupId, @model.discussionId, @model.parentId, Session.user().secretToken]).join('/')
      else
        [AppConfig.theme.channels_uri, 'tiptap', @model.constructor.singular, @model.id, (@model.secretToken || Session.user().secretToken)].join('/')

    selectedText: ->
      { selection, state } = @editor
      { from, to } = selection
      state.doc.textBetween(from, to, ' ')

    reset: ->
      @editor.clearContent()
      @resetFiles()

    convertToMd: ->
      if confirm I18n.t('formatting.markdown_confirm')
        convertToMd(@model, @field)
        Records.users.saveExperience('html-editor.uses-markdown')

    toggleExpanded: ->
      if !@expanded
        @expanded = true
        Records.users.saveExperience('html-editor.expanded')
      else
        @expanded = false
        Records.users.removeExperience('html-editor.expanded')

    setLinkUrl: (command) ->
      if @linkUrl
        @linkUrl = "http://".concat(@linkUrl) unless @linkUrl.includes("://")
        command({ href: @linkUrl })
        @linkUrl = null
      @linkDialogIsOpen = false
      @editor.focus()

    setIframeUrl: (command) ->
      command({ src: getEmbedLink(@iframeUrl) })
      @iframeUrl = null
      @iframeDialogIsOpen = false
      @editor.focus()

    emojiPicked: (shortcode, unicode) ->
      { view } = this.editor
      insertText(unicode)(view.state, view.dispatch, view)
      @closeEmojiMenu = false
      @editor.focus()

    updateModel: ->
      @model[@field] = @editor.getHTML()
      @updateFiles()

  beforeDestroy: ->
    @editor.destroy() if @editor
    # @socket.close() if @socket

</script>

<template lang="pug">
div
  //- template(v-if="!editor || loading")
  //-   | Connecting to socket server …
  .editor.mb-3
    editor-content.html-editor__textarea(ref="editor" :editor='editor').lmo-markdown-wrapper
    editor-menu-bar.menubar(:editor='editor' v-slot='{ commands, isActive, focused }')
      v-card(flat)
        v-layout(align-center v-if="isActive.table()")
          v-btn(icon @click="commands.deleteTable" :title="$t('formatting.remove_table')")
            v-icon mdi-table-remove
          v-btn(icon @click="commands.addColumnBefore" :title="$t('formatting.add_column_before')")
            v-icon mdi-table-column-plus-before
          v-btn(icon @click="commands.addColumnAfter" :title="$t('formatting.add_column_after')")
            v-icon mdi-table-column-plus-after
          v-btn(icon @click="commands.deleteColumn" :title="$t('formatting.remove_column')")
            v-icon mdi-table-column-remove
          v-btn(icon @click="commands.addRowBefore" :title="$t('formatting.add_row_before')")
            v-icon mdi-table-row-plus-before
          v-btn(icon @click="commands.addRowAfter" :title="$t('formatting.add_row_after')")
            v-icon mdi-table-row-plus-after
          v-btn(icon @click="commands.deleteRow" :title="$t('formatting.remove_row')")
            v-icon mdi-table-row-remove
          v-btn(icon @click="commands.toggleCellMerge" :title="$t('formatting.merge_selected')")
            v-icon mdi-table-merge-cells

        v-layout.py-2.justify-space-between.flex-wrap(align-center)
          section.d-flex.flex-wrap(:aria-label="$t('formatting.formatting_tools')")
            //- attach
            v-btn(icon @click='$refs.filesField.click()' :title="$t('formatting.attach')")
              v-icon mdi-paperclip

            //- v-btn(icon @click='$refs.imageFilesField.click()' :title="$t('formatting.insert_image')")
            //-   v-icon mdi-image

            //- link
            v-menu(:close-on-content-click="!selectedText()" v-model="linkDialogIsOpen" min-width="320px")
              template(v-slot:activator="{on, attrs}")
                v-btn(icon v-on="on" v-bind="attrs" :title="$t('formatting.link')")
                  v-icon mdi-link
              v-card
                template(v-if="selectedText()")
                  v-card-title.title(v-t="'text_editor.insert_link'")
                  v-card-text
                    v-text-field(type="url" label="https://www.example.com" v-model="linkUrl" autofocus ref="focus" v-on:keyup.enter="setLinkUrl(commands.link)")
                  v-card-actions
                    v-spacer
                    v-btn(color="primary" @click="setLinkUrl(commands.link)" v-t="'common.action.apply'")
                template(v-else)
                  v-card-title(v-t="'text_editor.select_text_to_link'")

            //- emoji
            v-menu(:close-on-content-click="false" v-model="closeEmojiMenu")
              template(v-slot:activator="{on, attrs}")
                v-btn.emoji-picker__toggle(v-on="on" v-bind="attrs" icon  :title="$t('formatting.insert_emoji')")
                  v-icon mdi-emoticon-outline
              emoji-picker(:insert="emojiPicked")

            //- headings menu
            //- v-menu
            //-   template(v-slot:activator="{ on, attrs }")
            //-     v-btn.drop-down-button(icon v-on="on" v-bind="attrs" :title="$t('formatting.heading_size')")
            //-       v-icon mdi-format-size
            //-       v-icon.menu-down-arrow mdi-menu-down
            //-   v-list(dense)
            //-     template(v-for="i in 3")
            //-       v-list-item(@click='commands.heading({ level: i })' :class="{ 'v-list-item--active': isActive.heading({level: i}) }")
            //-         v-list-item-icon
            //-           v-icon {{'mdi-format-header-'+i}}
            //-         v-list-item-title(v-t="'formatting.heading'+i")
            //-     v-list-item(@click='commands.paragraph()' :class="{ 'v-list-item--active': isActive.paragraph() }")
            //-       v-list-item-icon
            //-         v-icon mdi-format-pilcrow
            //-       v-list-item-title(v-t="'formatting.paragraph'")

            template(v-if="expanded")
              v-btn(icon @click='commands.paragraph()' :outlined="isActive.paragraph()" :title="$t('formatting.paragraph')")
                v-icon mdi-format-pilcrow
              template(v-for="i in 3")
                v-btn(icon @click='commands.heading({ level: i })' :outlined='isActive.heading({level: i})' :title="$t('formatting.heading'+i)")
                  v-icon {{'mdi-format-header-'+i}}

            //- bold

            v-btn(icon v-if="expanded" @click='commands.bold' :outlined="isActive.bold()" :title="$t('formatting.bold')")
              v-icon mdi-format-bold

            //- italic
            v-btn(icon v-if="expanded" @click='commands.italic' :outlined="isActive.italic()" :title="$t('formatting.italicize')")
              v-icon mdi-format-italic

            //- strikethrought
            v-btn(icon v-if="expanded" :outlined="isActive.strike()", @click='commands.strike' :title="$t('formatting.strikethrough')")
              v-icon mdi-format-strikethrough
            //- underline
            v-btn(icon v-if="expanded" :outlined="isActive.underline()", @click='commands.underline' :title="$t('formatting.underline')")
              v-icon mdi-format-underline

            text-highlight-btn(v-if="expanded" :editor="editor" :commands="commands")
            text-align-btn(v-if="expanded" :editor="editor" :commands="commands")

            //- list menu (always a menu)
            v-menu(v-if="expanded")
              template(v-slot:activator="{ on, attrs }")
                v-btn.drop-down-button(icon v-on="on" v-bind="attrs" :title="$t('formatting.lists')")
                  v-icon mdi-format-list-bulleted
                  v-icon.menu-down-arrow mdi-menu-down
              v-list(dense)
                v-list-item(@click='commands.todo_list')
                  v-list-item-icon
                    v-icon mdi-format-list-checks
                  v-list-item-title(v-t="'formatting.check_list'")
                v-list-item(@click='commands.bullet_list')
                  v-list-item-icon
                    v-icon mdi-format-list-bulleted
                  v-list-item-title(v-t="'formatting.bullet_list'")
                v-list-item(@click='commands.ordered_list')
                  v-list-item-icon
                    v-icon mdi-format-list-numbered
                  v-list-item-title(v-t="'formatting.number_list'")

            //- extra text marks
            template(v-if="expanded")
              //- strikethrough
              v-menu(:close-on-content-click="false" v-model="iframeDialogIsOpen" min-width="320px")
                template(v-slot:activator="{on}")
                  v-btn(icon v-on="on" :title="$t('formatting.embed')")
                    v-icon mdi-youtube
                v-card
                  v-card-title.title(v-t="'text_editor.insert_embedded_url'")
                  v-card-text
                    v-text-field(type="url" label="e.g. https://www.youtube.com/watch?v=Zlzuqsunpxc" v-model="iframeUrl" ref="focus" autofocus v-on:keyup.enter="setIframeUrl(commands.iframe)")
                  v-card-actions
                    v-spacer
                    v-btn(color="primary" @click="setIframeUrl(commands.iframe)" v-t="'common.action.apply'")
              //- blockquote
              v-btn(icon :outlined="isActive.blockquote()", @click='commands.blockquote' :title="$t('formatting.blockquote')")
                v-icon mdi-format-quote-close
              //- code block
              v-btn(small icon :outlined="isActive.code_block()", @click='commands.code_block' :title="$t('formatting.code_block')")
                v-icon mdi-code-braces
              //- embded
              v-btn(icon @click='commands.horizontal_rule' :title="$t('formatting.divider')")
                v-icon mdi-minus
              //- table
              v-btn(icon @click='commands.createTable({rowsCount: 3, colsCount: 3, withHeaderRow: false })' :title="$t('formatting.add_table')")
                v-icon mdi-table
              //- markdown (save experience)
              v-btn(icon @click="convertToMd" :title="$t('formatting.edit_markdown')")
                v-icon mdi-language-markdown-outline

            v-btn.html-editor__expand(v-if="!expanded" icon @click="toggleExpanded" :title="$t('formatting.expand')")
              v-icon mdi-chevron-right

            v-btn.html-editor__expand(v-if="expanded" icon @click="toggleExpanded" :title="$t('formatting.collapse')")
              v-icon mdi-chevron-left
          //- save button?
          v-spacer
          slot(v-if="!expanded" name="actions")
    div.d-flex(v-if="expanded" name="actions")
      v-spacer
      slot(name="actions")

    v-alert(v-if="maxLength && model[field] && model[field].length > maxLength" color='error')
      span( v-t="'poll_common.too_long'")

  suggestion-list(:query="query" :mentionable="mentionable" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex" @select-user="selectUser")
  files-list(:files="files" v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input(ref="filesField" type="file" name="files" multiple=true)
</template>
<style lang="sass">

// .count
//   display: flex
//   align-items: center
//   font-weight: bold
//   color: rgba(#000, 0.5)
//   color: #27b127
//   margin-bottom: 1rem
//   text-transform: uppercase
//   font-size: 0.7rem
//   line-height: 1
//   &:before
//     content: ''
//     display: inline-flex
//     background-color: #27b127
//     width: 0.4rem
//     height: 0.4rem
//     border-radius: 50%
//     margin-right: 0.3rem


.cursor
  color: #222
  text-align: center
  border-radius: 6px 6px 6px 0px
  padding: 5px
  margin-left: -4.5px
  position: absolute
  z-index: 1
  bottom: 5px
  left: -50%
  opacity: 0.85
  white-space: nowrap
  -webkit-touch-callout: none
  -webkit-user-select: none
  -khtml-user-select: none
  -moz-user-select: none
  -ms-user-select: none
  user-select: none
  &.me
    display: none
    &::after
      display: none
      border-color: inherit
  &.inactive
    opacity: 0.5
    &::after
      opacity: inherit
      border-color: inherit
  &::after
    content: ""
    position: absolute
    top: 100%
    left: 0%
    border-width: 5px
    border-style: solid
    border-color: inherit
    color: transparent


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

.ProseMirror
  outline: none

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
  .v-btn--icon
    width: 32px
    height: 32px

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

// .lmo-textarea img
//   display: block

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

.lmo-textarea p.is-empty:first-child::before
  content: attr(data-empty-text)
  float: left
  color: #aaa
  pointer-events: none
  height: 0

.lmo-textarea p.is-empty
  font-size: 16px
  padding-bottom: 16px

input[type="file"]
  display: none
</style>
