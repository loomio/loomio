<script lang="coffee">
import tippy from 'tippy.js'
import 'tippy.js/dist/tippy.css'
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
  TodoItem,
  TodoList,
  Image,
  Bold,
  Code,
  Italic,
  Link,
  Strike,
  Underline,
  History,
  Mention
} from 'tiptap-extensions'

import MentionMixin from './mention_mixin.coffee'
import MentionExtension from './mention_extension.coffee'

module.exports =
  props:
    model: Object
    field: String
    placeholder: Object
    helptext: Object
  components:
    EditorContent: EditorContent
    EditorMenuBar: EditorMenuBar
    EditorMenuBubble: EditorMenuBubble

  data: ->
    editor: null
    linkUrl: null
    linkMenuIsActive: false
    toggle_multiple: {}
    query: null,
    suggestionRange: null,
    filteredUsers: [],
    navigatedUserIndex: 0,
    insertMention: () => {},

  methods:
    showLinkMenu: (attrs) ->
      @linkUrl = attrs.href
      @linkMenuIsActive = true
      @$nextTick =>
        @$refs.linkInput.focus()

    hideLinkMenu: ->
      @linkUrl = null
      @linkMenuIsActive = false

    setLinkUrl: (command, url) ->
      command({ href: url })
      @hideLinkMenu()
      @editor.focus()

  mounted: ->
    @editor = new Editor
      extensions: [

          new Blockquote(),
          new BulletList(),
          new CodeBlock(),
          new HardBreak(),
          new Image(),
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
          new History()]
      content: '<p>This is just a boring paragraph</p>'

  beforeDestroy: ->
    @editor.destroy()
</script>

<template lang="pug">
.editor
  editor-menu-bubble.menububble.is-hidden(:editor='editor')
    .menububble(slot-scope='{ commands, isActive, getMarkAttrs, menu }', :class="{ 'is-active': menu.isActive }", :style='`left: ${menu.left}px; bottom: ${menu.bottom}px;`')
      form.menububble__form(v-if='linkMenuIsActive', @submit.prevent='setLinkUrl(commands.link, linkUrl)')
        input.menububble__input(type='text', v-model='linkUrl', placeholder='https://', ref='linkInput', @keydown.esc='hideLinkMenu')
        v-btn.menububble__button(icon @click='setLinkUrl(commands.link, null)')
          v-icon mdi-close-circle-outline
      template(v-else)
        v-btn.menububble__button(@click="showLinkMenu(getMarkAttrs('link'))", :class="{ 'is-active': isActive.link() }")
          span Link
          v-icon mdi-link

  editor-menu-bar(:editor='editor')
    .menubar(slot-scope='{ commands, isActive }')
      v-btn-toggle(v-model="toggle_multiple" multiple)
        v-btn.menubar__button(icon :class="{ 'is-active': isActive.bold() }", @click='commands.bold')
          v-icon mdi-format-bold
        v-btn.menubar__button(icon :class="{ 'is-active': isActive.italic() }", @click='commands.italic')
          v-icon mdi-format-italic
        v-btn.menubar__button(icon :class="{ 'is-active': isActive.strike() }", @click='commands.strike')
          v-icon mdi-format-strikethrough
        v-btn.menubar__button(icon :class="{ 'is-active': isActive.underline() }", @click='commands.underline')
          v-icon mdi-format-underline
        //- v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.code() }", @click='commands.code')
        //-   v-icon mdi-code-braces
        v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.paragraph() }", @click='commands.paragraph')
          v-icon mdi-format-pilcrow
        v-btn.menubar__v-btn(icon :class="{ 'is-active': isActive.heading({ level: 1 }) }", @click='commands.heading({ level: 1 })')
          v-icon mdi-format-header-1
        v-btn.menubar__v-btn(icon @click='commands.todo_list')
          v-icon mdi-format-list-checks
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
      //- v-btn.menubar__v-btn(icon @click='commands.undo')
      //-   v-icon mdi-undo
      //- v-btn.menubar__v-btn(icon @click='commands.redo')
      //-   v-icon mdi-redo
  editor-content.editor__content(:editor='editor').lmo-markdown-wrapper
</template>

<style lang="scss">
.menububble {
 position:absolute;
 display:flex;
 z-index:20;
 background:#000;
 border-radius:5px;
 padding:.3rem;
 margin-bottom:.5rem;
 transform:translateX(-50%);
 visibility:hidden;
 opacity:0;
 transition:opacity .2s,visibility .2s
}
.menububble.is-active {
 opacity:1;
 visibility:visible
}
.menububble__button {
 display:inline-flex;
 background:rgba(0,0,0,0);
 border:0;
 color:#fff;
 padding:.2rem .5rem;
 margin-right:.2rem;
 border-radius:3px;
 cursor:pointer
}
.menububble__button:last-child {
 margin-right:0
}
.menububble__button:hover {
 background-color:hsla(0,0%,100%,.1)
}
.menububble__button.is-active {
 background-color:hsla(0,0%,100%,.2)
}
.menububble__form {
 display:flex;
 align-items:center
}
.menububble__input {
 font:inherit;
 border:none;
 background:rgba(0,0,0,0);
 color:#fff
}

.menubar {
 margin-bottom:1rem;
 transition:visibility .2s .4s,opacity .2s .4s
}
.menubar.is-hidden {
 visibility:hidden;
 opacity:0
}
.menubar.is-focused {
 visibility:visible;
 opacity:1;
 transition:visibility .2s,opacity .2s
}
.menubar__button {
 font-weight:700;
 display:inline-flex;
 background:rgba(0,0,0,0);
 border:0;
 color:#000;
 padding:.2rem .5rem;
 margin-right:.2rem;
 border-radius:3px;
 cursor:pointer
}
.menubar__button:hover {
 background-color:rgba(0,0,0,.05)
}
.menubar__button.is-active {
 background-color:rgba(0,0,0,.1)
}

ul[data-type=todo_list] {
 padding-left:0
}
li[data-type=todo_item] {
 display:-webkit-box;
 display:-ms-flexbox;
 display:flex;
 -webkit-box-orient:horizontal;
 -webkit-box-direction:normal;
 -ms-flex-direction:row;
 flex-direction:row
}
.todo-checkbox {
 border:2px solid #000;
 height:.9em;
 width:.9em;
 -webkit-box-sizing:border-box;
 box-sizing:border-box;
 margin-right:10px;
 margin-top:.3rem;
 -moz-user-select:none;
 -ms-user-select:none;
 user-select:none;
 -webkit-user-select:none;
 cursor:pointer;
 border-radius:.2em;
 background-color:rgba(0,0,0,0);
 -webkit-transition:background .4s;
 transition:background .4s
}
.todo-content {
 -webkit-box-flex:1;
 -ms-flex:1;
 flex:1
}
li[data-done=true] {
 text-decoration:line-through
}
li[data-done=true] .todo-checkbox {
 background-color:#000
}
li[data-done=false] {
 text-decoration:none
}

.editor {
 position:relative
}
.editor__floating-menu {
 position:absolute;
 margin-top:-.25rem;
 visibility:hidden;
 opacity:0;
 -webkit-transition:opacity .2s,visibility .2s;
 transition:opacity .2s,visibility .2s
}
.editor__floating-menu.is-active {
 opacity:1;
 visibility:visible
}

$color-black: #000;
$color-white: #fff;

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

</style>
