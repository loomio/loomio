<script lang="js">
import { emojiReplaceText } from '@/shared/helpers/emojis';
import { merge } from 'lodash-es';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import AbilityService from '@/shared/services/ability_service';

export default {
  props: {
    model: {
      type: Object,
      required: true
    },
    column: {
      type: String,
      required: true
    }
  },

  mounted() {
    this.$el.addEventListener('click', this.onClick);
  },

  destroyed() {
    this.$el.removeEventListener('click', this.onClick);
  },

  methods: {
    onClick(e) {
      if ((e.target.getAttribute('data-type') === 'taskItem') && (e.offsetX < e.target.offsetLeft) && !e.target.classList.contains('task-item-busy')) {
        if (this.canEdit || e.target.querySelectorAll('span[data-mention-id="'+Session.user().username+'"]').length) {
          e.target.classList.add('task-item-busy');
          const uid = e.target.getAttribute('data-uid');
          const checked = e.target.getAttribute('data-checked') === 'true';
          const params = merge(this.model.namedId(), {uid, done: ((!checked && 'true') || 'false') });
          Records.remote.post('tasks/update_done', params).finally(() => {
            if (!checked) {
              Flash.success('tasks.task_updated_done');
            } else {
              Flash.success('tasks.task_updated_not_done');
            }
            e.target.classList.remove('task-item-busy');
          });
        } else {
          alert(this.$t('tasks.permission_denied'));
        }
      }
    }
  },

  computed: {
    canEdit() { return AbilityService.canEdit(this.model); },
    isMd() { return this.format === 'md'; },
    isHtml() { return this.format === 'html'; },
    format() { return this.model[this.column+"Format"]; },
    text() { return emojiReplaceText(this.model[this.column]); },
    hasTranslation() { if (this.model.translation) { return this.model.translation[this.column]; } },
    cookedText() {
      if (!this.model.mentionedUsernames) { return this.model[this.column]; }
      let cooked = this.model[this.column];
      this.model.mentionedUsernames.forEach(username => cooked = cooked.replace(new RegExp(`@${username}`, 'g'), `[@${username}](/u/${username})`));
      return cooked.replace(/^&gt; /, '> ').replace(/\n&gt; /, '\n> '); // fix for when > is encoded as &gt; by server
    }
  }
};
</script>

<template lang="pug">
div.lmo-markdown-wrapper
  div(v-if="!hasTranslation && isMd" v-marked='cookedText')
  div(v-if="!hasTranslation && isHtml" v-html='text')
  translation(v-if="hasTranslation" :model='model' :field='column')
</template>

<style lang="sass">

.v-theme--dark
  .lmo-markdown-wrapper
    hr
      border-bottom: 2px solid rgba(255, 255, 255, 0.5)
    p
      color: #FFFE

    blockquote
      background-color: rgba(0,0,0,0.3)
      border-left: 4px solid #000

img.emoji
  width: 1.4em !important
  vertical-align: top
  margin: 0 .05em

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
    background-color: var(--v-primary-lighten1)
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
    margin-top: 1rem
    margin-bottom: 0.75rem

  h1:first-child, h2:first-child, h3:first-child
    margin-top: 0

  h1
    font-size: 1.75rem
    font-weight: 400
    letter-spacing: 0.015625rem

  h2
    font-size: 1.25rem
    font-weight: 400
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
    max-height: 600px
    height: auto
    width: auto

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
      border-color: var(--v-grey-lighten1)
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
      border-color: var(--v-primary-lighten1)

    li.task-item-busy::before
      background-color: var(--v-primary-lighten1)
      border-color: var(--v-primary-lighten1)
      // background-color: none !important

  ol
    list-style: decimal

  li p
    margin-bottom: 8px

  pre
    overflow-x: auto
    font-family: 'Roboto mono', monospace, monospace
    white-space: pre-wrap

  code::before
    content: ''
    letter-spacing: normal

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
