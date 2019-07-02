<script lang="coffee">
import tippy from 'tippy.js'
# import 'tippy.js/dist/tippy.css'
import Records from '@/shared/services/records'
import {concat, sortBy, isString, filter, uniq, map, forEach} from 'lodash'
import FileUploader from '@/shared/services/file_uploader'
import FilesList from './files_list.vue'

import { Editor, EditorContent, EditorMenuBar, EditorMenuBubble } from 'tiptap'

import { Blockquote, CodeBlock, HardBreak, Heading, HorizontalRule,
  OrderedList, BulletList, ListItem, TodoList, Bold, Code,
  Italic, Link, Strike, Underline, History, Mention, Placeholder } from 'tiptap-extensions'

import TodoItem from './todo_item'

import { insertText } from 'tiptap-commands'
import Image from '@/shared/tiptap_extentions/image.js'

export default
  props:
    model: Object
    field: String
    placeholder: [String, Object]
    helptext: [String, Object]
    shouldReset: Boolean
    autoFocus:
      type: Boolean
      default: false

  components:
    EditorContent: EditorContent
    EditorMenuBar: EditorMenuBar
    FilesList: FilesList
    # EditorMenuBubble: EditorMenuBubble

  data: ->
    query: null
    suggestionRange: null
    files: []
    imageFiles: []
    mentionableUserIds: []
    navigatedUserIndex: 0
    closeEmojiMenu: false
    linkUrl: null
    linkDialogIsOpen: false
    insertMention: () => {}
    editor: new Editor
      extensions: [
        new Mention(
          # is called when a suggestion starts
          onEnter: ({ query, range, command, virtualNode }) =>
            # console.log "suggestion started", items, query, range
            @query = query
            @suggestionRange = range
            @insertMention = command
            @renderPopup(virtualNode)
            @fetchMentionable()

          # is called when a suggestion has changed
          onChange: ({query, range, virtualNode}) =>
            # console.log "suggestion changed", items, query, range
            @query = query
            @suggestionRange = range
            @navigatedUserIndex = 0
            @renderPopup(virtualNode)
            @fetchMentionable()

          # is called when a suggestion is cancelled
          onExit: =>
            @query = null
            @suggestionRange = null
            @navigatedUserIndex = 0
            @destroyPopup()

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

            # pressing enter
            if (event.keyCode == 13)
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
        new Bold(),
        new Code(),
        new Italic(),
        new Link(),
        new Strike(),
        new Underline(),
        new History(),
        new Placeholder({
          emptyClass: 'is-empty',
          emptyNodeText: @$lt(@placeholder),
          showOnlyWhenEditable: true,
        })
      ]
      content: @model[@field]
      onUpdate: @updateModel
      autoFocus: @autoFocus

  computed:
    hasResults: -> @filteredUsers.length
    showSuggestions: -> @query || @hasResults
    filteredUsers: ->
      unsorted = filter Records.users.collection.chain().find(@mentionableUserIds).data(), (u) =>
        isString(u.username) &&
        (u.name.toLowerCase().startsWith(@query) or
        (u.username || "").toLowerCase().startsWith(@query) or
        u.name.toLowerCase().includes(" #{@query}"))
      sortBy(unsorted, (u) -> (0 - Records.events.find(actorId: u.id).length))
    format: ->
      @model["#{@field}Format"]

  methods:
    setLinkUrl: (command) ->
      command({ href: @linkUrl })
      @linkUrl = null
      @linkDialogIsOpen = false
      @editor.focus()

    emitUploading: ->
      @$emit('is-uploading', !(@model.files.length == @files.length && @model.imageFiles.length == @imageFiles.length))

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

    fetchMentionable: ->
      Records.users.fetchMentionable(@query, @model).then (response) =>
        @mentionableUserIds.concat(uniq @mentionableUserIds + map(response.users, 'id'))

    # navigate to the previous item
    # if it's the first item, navigate to the last one
    upHandler: ->
      @navigatedUserIndex = ((@navigatedUserIndex + @filteredUsers.length) - 1) % @filteredUsers.length

    # navigate to the next item
    # if it's the last item, navigate to the first one
    downHandler: ->
      @navigatedUserIndex = (@navigatedUserIndex + 1) % @filteredUsers.length

    enterHandler: ->
      user = @filteredUsers[@navigatedUserIndex]
      @selectUser(user) if user

    # we have to replace our suggestion text with a mention
    # so it's important to pass also the position of your suggestion text
    selectUser: (user) ->
      @insertMention
        range: @suggestionRange
        attrs:
          id: user.id,
          label: user.name
      @editor.focus()

     # renders a popup with suggestions
     # tiptap provides a virtualNode object for using popper.js (or tippy.js) for popups
     renderPopup: (node) ->
       return if @popup
       @popup = tippy(node, {
         content: @$refs.suggestions,
         trigger: 'mouseenter',
         interactive: true,
         theme: 'dark',
         placement: 'top-start',
         performance: true,
         inertia: true,
         duration: [400, 200],
         showOnInit: true,
         arrow: true,
         arrowType: 'round'
       })

     destroyPopup: ->
       if (@popup)
         @popup.destroyAll()
         @popup = null
  watch:
    files: -> @updateModel()
    imageFiles: -> @updateModel()
    shouldReset: ->
      @editor.clearContent()
      @files = []
      @imageFiles = []

  beforeDestroy: ->
    @editor.destroy()
</script>

<template lang="pug">
div
  v-textarea(v-if="format == 'md'" lmo_textarea v-model="model[field]" :placeholder="$t('comment_form.say_something')")
  .editor.mb-4(v-if="format == 'html'")
    editor-menu-bar(:editor='editor' v-slot='{ commands, isActive, focused }')
      .menubar.is-hidden(:class="{'is-focused': focused}")
        v-menu
          template(v-slot:activator="{on}")
            v-btn(small text v-on="on")
              v-icon mdi-format-size
              v-icon mdi-menu-down
          v-list.menubar__dropdown
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.heading({ level: 1 }) }", @click='commands.heading({ level: 1 })')
                v-icon mdi-format-header-1
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.heading({ level: 2 }) }", @click='commands.heading({ level: 2 })')
                v-icon mdi-format-header-2
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.heading({ level: 3 }) }", @click='commands.heading({ level: 3 })')
                v-icon mdi-format-header-3
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.paragraph() }", @click='commands.paragraph')
                v-icon mdi-format-text
        v-menu
          template(v-slot:activator="{on}")
            v-btn(small text v-on="on")
              v-icon mdi-format-bold
              v-icon mdi-menu-down
          v-list.menubar__dropdown
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.bold() }", @click='commands.bold')
                v-icon mdi-format-bold
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.italic() }", @click='commands.italic')
                v-icon mdi-format-italic
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.strike() }", @click='commands.strike')
                v-icon mdi-format-strikethrough
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.underline() }", @click='commands.underline')
                v-icon mdi-format-underline
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.blockquote() }", @click='commands.blockquote')
                v-icon mdi-format-quote-close
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.code() }", @click='commands.code')
                v-icon mdi-code-braces
        v-menu
          template(v-slot:activator="{on}")
            v-btn(small text v-on="on")
              v-icon mdi-format-list-bulleted
              v-icon mdi-menu-down
          v-list.menubar__dropdown
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.bullet_list() }", @click='commands.bullet_list')
                v-icon mdi-format-list-bulleted
            v-list-item
              v-btn(small text :class="{ 'is-active': isActive.ordered_list() }", @click='commands.ordered_list')
                v-icon mdi-format-list-numbered
            v-list-item
              v-btn(small text @click='commands.todo_list')
                v-icon mdi-format-list-checks
        v-btn(text small :class="{ 'is-active': isActive.underline() }", @click='$refs.filesField.click()')
          v-icon mdi-paperclip
        v-menu(:close-on-content-click="false" v-model="closeEmojiMenu")
          template(v-slot:activator="{on}")
            v-btn.emoji-picker__toggle(v-on="on" small text :class="{ 'is-active': isActive.underline() }")
              v-icon mdi-emoticon-outline
          emoji-picker(:insert="emojiPicked")
        v-dialog(v-model="linkDialogIsOpen" max-width="600px")
          template(v-slot:activator="{on}")
            v-btn(text small v-on="on")
              v-icon mdi-link-variant
          v-card
            .needsSelection(v-if="editor.view.state.tr.selection.empty")
              v-card-title.title(v-t="'text_editor.select_text_to_link'")

            .hasSelection(v-if="!editor.view.state.tr.selection.empty")
              v-card-title.title(v-t="'text_editor.insert_link'")
              v-card-text
                v-text-field(type="url" label="https://www.example.com" v-model="linkUrl")
              v-card-actions
                v-spacer
                v-btn(color="primary" @click="setLinkUrl(commands.link)" v-t="'common.action.apply'")
        //-
        //- v-btn-toggle(slot-scope='{ commands, isActive }')
        //- v-btn(small icon :class="{ 'is-active': isActive.underline() }", @click='$refs.filesField.click()')
        //-   v-icon mdi-paperclip
        //- v-btn(small icon @click='commands.horizontal_rule')
        //-   v-icon mdi-format-page-break
    editor-content.editor__content(:editor='editor').lmo-markdown-wrapper

  .suggestion-list(v-show='showSuggestions', ref='suggestions')
    template(v-if='hasResults')
      .suggestion-list__item(v-for='(user, index) in filteredUsers', :key='user.id', :class="{ 'is-selected': navigatedUserIndex === index }", @click='selectUser(user)')
        | {{ user.name }}
    .suggestion-list__item.is-empty(v-else) No users found

  files-list(:files="files" v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input(ref="filesField" type="file" name="files" multiple=true)
</template>

<style lang="scss">
@import 'variables.scss';

.menubar.is-hidden {
  visibility: hidden;
  opacity: 0;
}
.menubar.is-focused {
  visibility: visible;
  opacity: 1;
  transition: visibility .1s .2s,opacity .1s .1s;
}
.menubar {
  margin-bottom: 1rem;
}


.lmo-markdown-wrapper {
  word-wrap: break-word;

  // p { @include md-body-1; }
  img { max-width: 100%; }
  h1 {
    // @include fontLarge;
    margin: 1em 0 0.5em;
    font-weight: 500;
  }
  h2 {
    // @include fontMedLarge;
    margin: 1em 0 0.5em;
    font-weight: 500;
  }
  h3 {
    margin: 1em 0 0.5em;
    font-weight: 500;
  }
  ul{ padding: 0 0 10px 24px; }
  ul li{ list-style: disc; }
  pre {
    overflow: auto;
    padding: 10px;
    // background: $modal-background-color;
  }
  blockquote{
    font-style: italic;
    font-size: inherit;
  }
  table {
    table-layout: fixed;
    width: 100%;
    margin-bottom: 10px;
  }
  table td {
    padding: 6px 13px;
    border: 1px solid #ddd;
  }
  thead td { font-weight: bold; }
}

$color-black: #000;
$color-white: #fff;

progress {
  -webkit-appearance: none;
  appearance: none;
  background-color: #fff;
  border: 1px solid #ccc;
}

progress::-webkit-progress-bar {
  background-color: #fff;
  border: 1px solid #ccc;
}

progress::-webkit-progress-value {
  background-color: lightblue;
  border: 0;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
}

progress::-moz-progress-bar {
  background-color: lightblue;
  border: 0;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
}

.menubar__dropdown {
  .v-list__tile {
    height: 40px;;

    .v-btn {
      margin-left: 0;
      margin-right: 0;
      min-width: 0;
      .v-icon {
        font-size: 16px;
        // color: #aaa;
      }
    }
  }
}

.menubar {
  .v-btn--icon {
    width: 32px;
    height: 32px;
  }
  .v-btn {
    min-width: 0;
    margin-left: 0;
    margin-right: 0;
    .v-icon {
      font-size: 16px;
      // color: $grey-on-white;
    }
  }
}

.ProseMirror {
  border-bottom: 1px solid #999;
  padding: 4px 0px;
  margin: 4px 0px;
  outline: none;
}

.ProseMirror:focus {
  border-bottom: 2px solid var(--v-primary-base);
}

.ProseMirror img {
  display: block;
}

.ProseMirror progress {
  // display: block;
}

ul[data-type="todo_list"] {
  padding-left: 0;
}
li[data-type="todo_item"] {
  display: flex;
  flex-direction: row;
}

.todo-checkbox {
  border: 2px solid #000;
  height: 0.9em;
  width: 0.9em;
  box-sizing: border-box;
  margin-right: 10px;
  margin-top: 0.3rem;
  user-select: none;
  -webkit-user-select: none;
  cursor: pointer;
  border-radius: 0.2em;
  background-color: transparent;
  transition: 0.4s background;
}

.todo-content {
  flex: 1;
  > p:last-of-type {
    margin-bottom: 0;
  }
  > ul[data-type="todo_list"] {
    margin: .5rem 0;
  }
}
li[data-done="true"] {
  > .todo-content {
    > p {
      text-decoration: line-through;
    }
  }
  > .todo-checkbox {
    background-color: #000;
  }
}
li[data-done="false"] {
  text-decoration: none;
}
// .ProseMirror::after{
//   bottom: -1px;
//   content: "";
//   left: 0;
//   position: absolute;
//   -webkit-transition: 0.3s cubic-bezier(0.25, 0.8, 0.5, 1);
//   transition: 0.3s cubic-bezier(0.25, 0.8, 0.5, 1);
//   width: 100%;
// }

.editor p.is-empty:first-child::before {
  content: attr(data-empty-text);
  float: left;
  color: #aaa;
  pointer-events: none;
  height: 0;
  // font-style: italic;
}
.editor p.is-empty {
  font-size: 16px;
}

.mention {
  background: rgba($color-black, 0.1);
  color: rgba($color-black, 0.6);
  font-size: 0.8rem;
  font-weight: bold;
  border-radius: 5px;
  padding: 0.2rem 0.5rem;
  white-space: nowrap;
}

.mention-suggestion {
  color: rgba($color-black, 0.6);
}

.suggestion-list {
  padding: 0.2rem;
  border: 2px solid rgba($color-black, 0.1);
  font-size: 0.8rem;
  font-weight: bold;
  &__no-results {
    padding: 0.2rem 0.5rem;
  }
  &__item {
    border-radius: 5px;
    padding: 0.2rem 0.5rem;
    margin-bottom: 0.2rem;
    cursor: pointer;
    &:last-child {
      margin-bottom: 0;
    }
    &.is-selected,
    &:hover {
      background-color: rgba($color-white, 0.2);
    }
    &.is-empty {
      opacity: 0.5;
    }
  }
}

.tippy-tooltip.dark-theme {
  background-color: $color-black;
  padding: 0;
  font-size: 1rem;
  text-align: inherit;
  color: $color-white;
  border-radius: 5px;
  .tippy-backdrop {
    display: none;
  }
  .tippy-roundarrow {
    fill: $color-black;
  }
  .tippy-popper[x-placement^=top] & .tippy-arrow {
    border-top-color: $color-black;
  }
  .tippy-popper[x-placement^=bottom] & .tippy-arrow {
    border-bottom-color: $color-black;
  }
  .tippy-popper[x-placement^=left] & .tippy-arrow {
    border-left-color: $color-black;
  }
  .tippy-popper[x-placement^=right] & .tippy-arrow {
    border-right-color: $color-black;
  }
}

input[type="file"] { display: none; }
</style>
