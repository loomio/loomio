<script lang="coffee">
import tippy from 'tippy.js'
import 'tippy.js/dist/tippy.css'
import Records from 'shared/services/records'
import _concat from 'lodash/concat'
import _sortBy from 'lodash/sortBy'
import _isString from 'lodash/isString'
import _filter from 'lodash/filter'
import _uniq from 'lodash/uniq'
import _map from 'lodash/map'
import _forEach from 'lodash/forEach'
import FileUploader from 'shared/services/file_uploader'
import FilesList from './files_list.vue'

import { Editor, EditorContent, EditorMenuBar, EditorMenuBubble } from 'tiptap'

import { Blockquote, CodeBlock, HardBreak, Heading, HorizontalRule,
  OrderedList, BulletList, ListItem, TodoItem, TodoList, Bold, Code,
  Italic, Link, Strike, Underline, History, Mention, Placeholder } from 'tiptap-extensions'
import Image from 'shared/tiptap_extentions/image.js'

module.exports =
  props:
    model: Object
    field: String
    placeholder: Object
    helptext: Object
    saving: Boolean
  components:
    EditorContent: EditorContent
    EditorMenuBar: EditorMenuBar
    FilesList: FilesList
    # EditorMenuBubble: EditorMenuBubble

  watch:
    saving: ->
      @updateModel()

  data: ->
    query: null
    suggestionRange: null
    files: []
    mentionableUserIds: []
    navigatedUserIndex: 0
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
        new Image({attachFile: @attachFile}),
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
          emptyNodeText: 'Write something …',
          showOnlyWhenEditable: true,
        })
      ]
      content: @model[@field]
      # onUpdate: ({ getJSON, getHTML }) =>
      #   @model[@field] = getHTML()
      #   @model["#{@field}Format"] = "html"

  computed:
    hasResults: -> @filteredUsers.length
    showSuggestions: -> @query || @hasResults
    filteredUsers: ->
      unsorted = _filter Records.users.collection.chain().find(@mentionableUserIds).data(), (u) =>
        _isString(u.username) &&
        (u.name.toLowerCase().startsWith(@query) or
        (u.username || "").toLowerCase().startsWith(@query) or
        u.name.toLowerCase().includes(" #{@query}"))
      _sortBy(unsorted, (u) -> (0 - Records.events.find(actorId: u.id).length))

  methods:
    updateModel: ->
      console.log("updating model with textarea html")
      @model[@field] = @editor.getHTML()
      # @model.files ...

    removeFile: (name) ->
      @files = _filter @files, (wrapper) -> wrapper.file.name != name

    attachFile: (file) ->
      wrapper = {file: file, key: file.name+file.size, percentComplete: 0, blob: null, xhr: null}
      @files.push(wrapper)
      fileCallbacks = {
        progress: (e) ->
          if (e.lengthComputable)
            wrapper.percentComplete = parseInt(e.loaded / e.total * 100);
      }
      uploader = new FileUploader(fileCallbacks)
      uploader.upload(file).then (blob) => wrapper.blob = blob

    fileSelected: -> _forEach @$refs.filesField.files, @attachFile

    fetchMentionable: ->
      Records.users.fetchMentionable(@query, @model).then (response) =>
        @mentionableUserIds.concat(_.uniq @mentionableUserIds + _.map(response.users, 'id'))

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

  beforeDestroy: ->
    @editor.destroy()
</script>

<template lang="pug">
div
  .editor
    editor-menu-bar(:editor='editor')
      .menubar(slot-scope='{ commands, isActive }')
        v-btn-toggle
          v-btn.menubar__button(icon :class="{ 'is-active': isActive.bold() }", @click='commands.bold')
            v-icon mdi-format-bold
          v-btn.menubar__button(icon :class="{ 'is-active': isActive.italic() }", @click='commands.italic')
            v-icon mdi-format-italic
          v-btn.menubar__button(icon :class="{ 'is-active': isActive.strike() }", @click='commands.strike')
            v-icon mdi-format-strikethrough
          v-btn.menubar__button(icon :class="{ 'is-active': isActive.underline() }", @click='commands.underline')
            v-icon mdi-format-underline
          v-btn.menubar__button(icon :class="{ 'is-active': isActive.underline() }", @click='$refs.filesField.click()')
            v-icon mdi-paperclip
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.code() }", @click='commands.code')
          //-   v-icon mdi-code-braces
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.paragraph() }", @click='commands.paragraph')
          //-   v-icon mdi-format-pilcrow
          //- v-btn.menubar__v-btn(icon @click='commands.todo_list')
          //-   v-icon mdi-format-list-checks
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.heading({ level: 1 }) }", @click='commands.heading({ level: 1 })')
          //-   v-icon mdi-format-header-1
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.heading({ level: 2 }) }", @click='commands.heading({ level: 2 })')
          //-   v-icon mdi-format-header-2
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.heading({ level: 3 }) }", @click='commands.heading({ level: 3 })')
          //-   v-icon mdi-format-header-3
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.bullet_list() }", @click='commands.bullet_list')
          //-   v-icon mdi-format-list-bulleted
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.ordered_list() }", @click='commands.ordered_list')
          //-   v-icon mdi-format-list-numbered
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.blockquote() }", @click='commands.blockquote')
          //-   v-icon mdi-format-quote-closed
          //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.code_block() }", @click='commands.code_block')
          //-   v-icon mdi-code-tags
          //- v-btn.menubar__v-btn(icon @click='commands.horizontal_rule')
          //-   v-icon mdi-format-page-break
          v-btn.menubar__v-btn(icon @click='commands.undo')
            v-icon mdi-undo
          v-btn.menubar__v-btn(icon @click='commands.redo')
            v-icon mdi-redo
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

$color-black: #000;
$color-white: #fff;

progress {
  -webkit-appearance: none;
  appearance: none;
  background-color: $color-white;
  border: 1px solid $border-color;
}

progress::-webkit-progress-bar {
  background-color: $color-white;
  border: 1px solid $border-color;
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

.ProseMirror {
  border: 2px solid $border-color;
  border-radius: 4px;
  outline: none;
}

.ProseMirror:focus {
  border-color: var(--v-accent-base);
}

.ProseMirror img {
  display: block;
}

.editor p.is-empty:first-child::before {
  content: attr(data-empty-text);
  float: left;
  color: #aaa;
  pointer-events: none;
  height: 0;
  font-style: italic;
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

ul[data-type="todo_list"] {
  padding-left: 0;
}

li[data-type="todo_item"] {
  display: flex;
  flex-direction: row;
}

.todo-checkbox {
  border: 2px solid $color-black;
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
}

li[data-done="true"] {
  text-decoration: line-through;
}
li[data-done="true"] .todo-checkbox {
  background-color: $color-black;
}
li[data-done="false"] {
  text-decoration: none;
}
</style>
