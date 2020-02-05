<script lang="coffee">
import { detect } from 'detect-browser'
import Records from '@/shared/services/records'
import {concat, sortBy, isString, filter, uniq, map, forEach, isEmpty} from 'lodash'
import FileUploader from '@/shared/services/file_uploader'
import FilesList from './files_list.vue'
import detectIt from 'detect-it'
import EventBus from '@/shared/services/event_bus'
import { convertToMd } from '@/shared/services/format_converter'

import { Editor, EditorContent, EditorMenuBar, EditorMenuBubble } from 'tiptap'

import {
  Blockquote,
  CodeBlock,
  HardBreak,
  Heading,
  HorizontalRule,
  OrderedList,
  BulletList,
  ListItem,
  Table,
  TableHeader,
  TableCell,
  TableRow,
  TodoList,
  Bold,
  Code,
  Italic,
  Link,
  Strike,
  Underline,
  History,
  Mention,
  Placeholder,
  TrailingNode } from 'tiptap-extensions'

import ExternalLink from './external_link'
import Iframe from './iframe'
import TodoItem from './todo_item'

import { insertText } from 'tiptap-commands'
import Image from '@/shared/tiptap_extentions/image.js'

import {getEmbedLink} from '@/shared/helpers/embed_link.coffee'

import Mentioning from './mentioning.coffee'
import SuggestionList from './suggestion_list'

export default
  mixins: [Mentioning]
  props:
    model: Object
    field: String
    label: String
    placeholder: String
    shouldReset: Boolean
    maxLength: Number
    autoFocus:
      type: Boolean
      default: false

  components:
    EditorContent: EditorContent
    EditorMenuBar: EditorMenuBar
    FilesList: FilesList
    EditorMenuBubble: EditorMenuBubble
    SuggestionList: SuggestionList

  data: ->
    query: null
    moreButtons: false
    suggestionRange: null
    files: []
    imageFiles: []
    mentionableUserIds: []
    navigatedUserIndex: 0
    suggestionListStyles: {}
    closeEmojiMenu: false
    linkUrl: "https://"
    iframeUrl: ""
    linkDialogIsOpen: false
    iframeDialogIsOpen: false
    insertMention: () => {}
    editor: new Editor
      disablePasteRules: true
      editorProps:
        scrollThreshold: 100
        scrollMargin: 100
      extensions: [
        new Mention(
          # is called when a suggestion starts
          onEnter: ({ query, range, command, virtualNode }) =>
            @query = query.toLowerCase()
            @suggestionRange = range
            @insertMention = command
            @updatePopup(virtualNode)
            @fetchMentionable()

          # is called when a suggestion has changed
          onChange: ({query, range, virtualNode}) =>
            @query = query.toLowerCase()
            @suggestionRange = range
            @navigatedUserIndex = 0
            @updatePopup(virtualNode)
            @fetchMentionable()

          # is called when a suggestion is cancelled
          onExit: =>
            @query = null
            @suggestionRange = null
            @navigatedUserIndex = 0

          # is called on every keyDown event while a suggestion is active
          onKeyDown: ({ event }) =>
            # pressing up arrow
            if (event.keyCode == 38)
              @upHandler()
              return true

            # pressing down arrow
            if (event.keyCode == 40)
              @downHandler()
              return true

            # pressing enter or tab
            if [13,9].includes(event.keyCode)
              @enterHandler()
              return true

            return false
        ),

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
        new ExternalLink(),
        new Strike(),
        new Underline(),
        new History(),
        new Iframe(),
        new Placeholder({
          emptyClass: 'is-empty',
          emptyNodeText: @placeholder,
          showOnlyWhenEditable: true,
        }),
        new TrailingNode({node: 'paragraph', notAfter: ['paragraph']})
      ]
      content: @model[@field]
      onUpdate: @updateModel
      autoFocus: @autoFocus

  computed:
    format: ->
      @model["#{@field}Format"]

    inlineBubbleMenu: ->
      browser = detect()
      browser.name == 'firefox' || browser.name == 'safari' || detectIt.primaryInput == 'touch'

  created: ->
    @files = @model.attachments.filter((a) -> a.signed_id).map((a) -> {blob: a, file: {name: a.filename}})

  mounted: ->
    @updateModel()

  methods:
    convertToMd: convertToMd
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

    emitUploading: ->
      @$emit('is-uploading', !((@model.files || []).length == @files.length && (@model.imageFiles || []).length == @imageFiles.length))

    emojiPicked: (shortcode, unicode) ->
      { view } = this.editor
      insertText(unicode)(view.state, view.dispatch, view)
      @closeEmojiMenu = false
      @editor.focus()

    updateModel: ->
      @model[@field] = @editor.getHTML()
      @model.files = @files.filter((w) => w.blob).map (wrapper) => wrapper.blob.signed_id
      @model.imageFiles = @imageFiles.filter((w) => w.blob).map (wrapper) => wrapper.blob.signed_id
      @emitUploading()

    removeFile: (name) ->
      @files = filter @files, (wrapper) -> wrapper.file.name != name

    attachFile: ({file}) ->
      wrapper = {file: file, key: file.name+file.size, percentComplete: 0, blob: null}
      @files.push(wrapper)
      @emitUploading()
      uploader = new FileUploader onProgress: (e) ->
        wrapper.percentComplete = parseInt(e.loaded / e.total * 100)

      uploader.upload(file).then (blob) =>
        wrapper.blob = blob
        @updateModel()
      ,
      (e) ->
        console.log "attachment failed to upload"

    attachImageFile: ({file, onProgress, onComplete, onFailure}) ->
      wrapper = {file: file, blob: null}
      @imageFiles.push(wrapper)
      @emitUploading()
      uploader = new FileUploader onProgress: onProgress
      uploader.upload(file).then((blob) =>
        wrapper.blob = blob
        onComplete(blob)
        @updateModel()
      , onFailure)

    fileSelected: ->
      forEach(@$refs.filesField.files, (file) => @attachFile(file: file))

    upHandler: ->
      @navigatedUserIndex = ((@navigatedUserIndex + @filteredUsers.length) - 1) % @filteredUsers.length

    downHandler: ->
      @navigatedUserIndex = (@navigatedUserIndex + 1) % @filteredUsers.length

    enterHandler: ->
      user = @filteredUsers[@navigatedUserIndex]
      @selectUser(user) if user

    selectUser: (user) ->
      @insertMention
        range: @suggestionRange
        attrs:
          id: user.username,
          label: user.name
      @editor.focus()

    updatePopup: (node) ->
      coords = node.getBoundingClientRect()
      @suggestionListStyles =
        position: 'fixed'
        top: coords.y + 24 + 'px'
        left: coords.x + 'px'

    reset: ->
      @editor.clearContent()
      @files = []
      @imageFiles = []

  watch:
    linkDialogIsOpen: (val) ->
      return unless val && @$refs.focus
      requestAnimationFrame => @$refs.focus.focus()
    iframeDialogIsOpen: (val) ->
      return unless val && @$refs.focus
      requestAnimationFrame => @$refs.focus.focus()
    files: -> @updateModel()
    imageFiles: -> @updateModel()
    shouldReset: -> @reset()

  beforeDestroy: ->
    @editor.destroy()
</script>

<template lang="pug">
div
  label.caption.v-label.v-label--active.theme--light {{label}}
  .editor.mb-3
    editor-content.html-editor__textarea(:editor='editor').lmo-markdown-wrapper
    editor-menu-bar(:editor='editor' v-slot='{ commands, isActive, focused }')
      div
        v-layout.menubar(align-center v-if="isActive.table()")
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
        v-layout.menubar.py-2(align-center)
          v-layout(style="overflow: scroll")
            v-menu(:close-on-content-click="false" v-model="closeEmojiMenu")
              template(v-slot:activator="{on}")
                v-btn.emoji-picker__toggle(v-on="on" icon)
                  v-icon mdi-emoticon-outline
              emoji-picker(:insert="emojiPicked")
            v-btn(icon @click="linkDialogIsOpen = true" :title="$t('formatting.link')")
              v-icon mdi-link
            v-dialog(v-model="linkDialogIsOpen" max-width="600px")
              v-card
                v-card-title.title(v-t="'text_editor.insert_link'")
                v-card-text
                  v-text-field(type="url" label="https://www.example.com" v-model="linkUrl" autofocus ref="focus" v-on:keyup.enter="setLinkUrl(commands.link)")
                v-card-actions
                  v-spacer
                  v-btn(color="primary" @click="setLinkUrl(commands.link)" v-t="'common.action.apply'")
            v-btn(icon @click='$refs.filesField.click()' :title="$t('formatting.attach')")
              v-icon mdi-paperclip

            v-btn(icon :outlined="isActive.bold()", @click='commands.bold' :title="$t('formatting.bold')")
              v-icon mdi-format-bold
            v-btn(icon :outlined="isActive.italic()", @click='commands.italic' :title="$t('formatting.italicize')")
              v-icon mdi-format-italic
            v-btn(v-if="moreButtons" icon :outlined="isActive.strike()", @click='commands.strike' :title="$t('formatting.strikethrough')")
              v-icon mdi-format-strikethrough
            v-btn(v-if="moreButtons" icon :outlined="isActive.underline()", @click='commands.underline' :title="$t('formatting.underline')")
              v-icon mdi-format-underline
            v-btn(v-if="moreButtons" icon :outlined="isActive.blockquote()", @click='commands.blockquote' :title="$t('formatting.blockquote')")
              v-icon mdi-format-quote-close

            v-btn(v-if="moreButtons" small icon :outlined="isActive.code_block()", @click='commands.code_block' :title="$t('formatting.code_block')")
              v-icon mdi-code-braces
            v-menu
              template(v-slot:activator="{ on }")
                v-btn.drop-down-button(icon v-on="on")
                  v-icon mdi-format-size
                  v-icon.menu-down-arrow mdi-menu-down
              v-list(dense)
                v-list-item(@click='commands.heading({ level: 1 })' :class="{ 'v-list-item--active': isActive.heading({level: 1}) }")
                  v-list-item-icon
                    v-icon mdi-format-header-1
                  v-list-item-title(v-t="'formatting.heading1'")
                v-list-item(@click='commands.heading({ level: 2 })' :class="{ 'v-list-item--active': isActive.heading({level: 2}) }")
                  v-list-item-icon
                    v-icon mdi-format-header-2
                  v-list-item-title(v-t="'formatting.heading2'")
                v-list-item(@click='commands.heading({ level: 3 })'  :class="{ 'v-list-item--active': isActive.heading({level: 3}) }")
                  v-list-item-icon
                    v-icon mdi-format-header-3
                  v-list-item-title(v-t="'formatting.heading3'" )
                v-list-item(@click='commands.paragraph()' :class="{ 'v-list-item--active': isActive.paragraph() }")
                  v-list-item-icon
                    v-icon mdi-format-pilcrow
                  v-list-item-title(v-t="'formatting.paragraph'")
            v-menu
              template(v-slot:activator="{ on }")
                v-btn.drop-down-button(icon v-on="on")
                  v-icon mdi-format-list-bulleted
                  v-icon.menu-down-arrow mdi-menu-down
              v-list(dense)
                v-list-item(@click='commands.bullet_list')
                  v-list-item-icon
                    v-icon mdi-format-list-bulleted
                  v-list-item-title(v-t="'formatting.bullet_list'")
                v-list-item(@click='commands.ordered_list')
                  v-list-item-icon
                    v-icon mdi-format-list-numbered
                  v-list-item-title(v-t="'formatting.number_list'")
                v-list-item(@click='commands.todo_list')
                  v-list-item-icon
                    v-icon mdi-format-list-checks
                  v-list-item-title(v-t="'formatting.check_list'")

            v-btn(v-if="moreButtons" icon @click='iframeDialogIsOpen = true' :title="$t('formatting.embed')")
              v-icon mdi-youtube

            v-btn(v-if="moreButtons" icon @click='commands.horizontal_rule' :title="$t('formatting.divider')")
              v-icon mdi-minus

            v-btn(v-if="moreButtons" icon @click='commands.createTable({rowsCount: 3, colsCount: 3, withHeaderRow: false })' :title="$t('formatting.add_table')")
              v-icon mdi-table

            v-btn(v-if="moreButtons" icon @click="convertToMd(model, field)" :title="$t('formatting.switch_to_markdown')")
              v-icon mdi-markdown

            v-dialog(v-model="iframeDialogIsOpen" max-width="600px")
              v-card
                v-card-title.title(v-t="'text_editor.insert_embedded_url'")
                v-card-text
                  v-text-field(type="url" label="e.g. https://www.youtube.com/embed/fuWfEwlWFlw" v-model="iframeUrl" ref="focus" autofocus v-on:keyup.enter="setIframeUrl(commands.iframe)")
                v-card-actions
                  v-spacer
                  v-btn(color="primary" @click="setIframeUrl(commands.iframe)" v-t="'common.action.apply'")

            v-btn(icon @click="moreButtons = !moreButtons")
              v-icon(v-if="!moreButtons") mdi-chevron-right
              v-icon(v-if="moreButtons") mdi-chevron-left

          slot(name="actions")
    v-alert(v-if="maxLength && model[field] && model[field].length > maxLength" color='error')
      span( v-t="'poll_common.too_long'")

  suggestion-list(:query="query" :filtered-users="filteredUsers" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex")
  files-list(:files="files" v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input(ref="filesField" type="file" name="files" multiple=true)
</template>

<style lang="sass">
progress
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
  background-color: #fff

.menubar
  .drop-down-button
    width: 40px !important
  .menu-down-arrow
    margin-left: -10px
  .v-btn--icon
    width: 32px
    height: 32px

  .v-btn
    min-width: 0
    margin-left: 0
    margin-right: 0
    .v-icon
      font-size: 16px

.html-editor__textarea
  border-bottom: 1px solid #999
  padding: 4px 0px
  margin: 4px 0px
  outline: none
  overflow-y: scroll

.html-editor__textarea:focus
  border-bottom: 2px solid var(--v-primary-base)

// .lmo-textarea img
//   display: block

ul[data-type="todo_list"]
  padding-left: 0
li[data-type="todo_item"]
  display: flex
  flex-direction: row

.todo-checkbox
  border: 1px solid #999
  height: 1em
  width: 1em
  box-sizing: border-box
  margin-right: 8px
  margin-top: 4px
  user-select: none
  border-radius: 0.2em
  background-color: transparent

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
    top: -7px
    color: var(--v-primary-base)
    font-size: 1.3rem
    content: "✓"

li[data-done="false"]
  text-decoration: none

.editor p.is-empty:first-child::before
  content: attr(data-empty-text)
  float: left
  color: #aaa
  pointer-events: none
  height: 0

.editor p.is-empty
  font-size: 16px
  padding-bottom: 16px

input[type="file"]
  display: none
</style>
