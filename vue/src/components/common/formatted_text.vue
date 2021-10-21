<script lang="coffee">
import { emojiReplaceText } from '@/shared/helpers/emojis.coffee'
import { merge } from 'lodash'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import AbilityService from '@/shared/services/ability_service'

export default
  props:
    model:
      type: Object
      required: true
    column:
      type: String
      required: true

  mounted: ->
    @$el.addEventListener 'click', @onClick

  destroyed: ->
    @$el.removeEventListener 'click', @onClick

  methods:
    onClick: (e) ->
      if e.target.getAttribute('data-type') == 'taskItem' && (e.offsetX < e.target.offsetLeft) && !e.target.classList.contains('task-item-busy')
        if (@canEdit || e.target.querySelectorAll('span[data-mention-id="'+Session.user().username+'"]').length)
          e.target.classList.add('task-item-busy')
          uid = e.target.getAttribute('data-uid')
          checked = e.target.getAttribute('data-checked') == 'true'
          params = merge(@model.namedId(), {uid: uid, done: ((!checked && 'true') || 'false') })
          Records.remote.post('tasks/update_done', params).finally =>
            if !checked
              Flash.success 'tasks.task_updated_done'
            else
              Flash.success 'tasks.task_updated_not_done'
            e.target.classList.remove('task-item-busy')
        else
          alert(@$t('tasks.permission_denied'))

  computed:
    canEdit: -> AbilityService.canEdit(@model)
    isMd: -> @format == 'md'
    isHtml: -> @format == 'html'
    format: -> @model[@column+"Format"]
    text: -> emojiReplaceText(@model[@column])
    hasTranslation: -> @model.translation[@column] if @model.translation
    cookedText: ->
      return @model[@column] unless @model.mentionedUsernames
      cooked = @model[@column]
      @model.mentionedUsernames.forEach (username) ->
        cooked = cooked.replace(///@#{username}///g, "[@#{username}](/u/#{username})")
      cooked
</script>

<template lang="pug">
div.lmo-markdown-wrapper
  div(v-if="!hasTranslation && isMd" v-marked='cookedText')
  div(v-if="!hasTranslation && isHtml" v-html='text')
  translation(v-if="hasTranslation" :model='model' :field='column')
</template>

<style lang="sass">
@import '~vuetify/src/styles/settings/_colors'

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

.theme--dark
  .lmo-markdown-wrapper
    span[style="color:#000000"],
    span[style="color:#000000;"],
    span[style="color: #000000"],
    span[style="color: #000000;"],
    span[style="color:#000"],
    span[style="color: #000;"],
    span[style="color:rgba(0, 0, 0, 0.87);"],
    span[style="color:rgba(0, 0, 0, 0.87)"],
    span[style="color:rgba(0, 0, 0, 1);"],
    span[style="color:rgba(0, 0, 0, 1)"],
    span[style="color:rgb(0, 0, 0);"],
    span[style="color:rgb(0, 0, 0)"],
    span[style="color:rgb(0,0,0);"],
    span[style="color:rgb(0,0,0)"],
    span[style="color: rgba(0, 0, 0, 0.87);"],
    span[style="color: rgba(0, 0, 0, 0.87)"],
    span[style="color: rgba(0, 0, 0, 1);"],
    span[style="color: rgba(0, 0, 0, 1)"],
    span[style="color: rgb(0, 0, 0);"],
    span[style="color: rgb(0, 0, 0)"],
    span[style="color: rgb(0,0,0);"],
    span[style="color: rgb(0,0,0)"]
      color: #fff !important

.theme--light
  .lmo-markdown-wrapper
    span[style="color:rgb(255, 255, 255);"],
    span[style="color:rgb(255, 255, 255)"],
    span[style="color: rgb(255, 255, 255);"],
    span[style="color: rgb(255, 255, 255)"],
    span[style="color:rgb(255,255,255);"],
    span[style="color:rgb(255,255,255)"],
    span[style="color: rgb(255,255,255);"],
    span[style="color: rgb(255,255,255)"],
    span[style="color: #fff"],
    span[style="color: #fff;"],
    span[style="color:#fff"],
    span[style="color:#fff;"],
    span[style="color: #ffffff"],
    span[style="color: #ffffff;"],
    span[style="color:#ffffff"],
    span[style="color:#ffffff;"]
      color: rgba(0, 0, 0, 0.87) !important

.lmo-markdown-wrapper

  a
    text-decoration: underline
  p
    margin-bottom: 0.5rem

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
    background-color: map-get($red, lighten-1)
  mark[data-color="pink"]
    background-color: map-get($pink, lighten-3)
  mark[data-color="purple"]
    background-color: map-get($purple, lighten-3)
  mark[data-color="blue"]
    background-color: map-get($blue, lighten-3)
  mark[data-color="green"]
    background-color: map-get($green, lighten-3)
  mark[data-color="yellow"]
    background-color: map-get($yellow, lighten-3)
  mark[data-color="orange"]
    background-color: map-get($orange, lighten-3)
  mark[data-color="brown"]
    background-color: map-get($brown, lighten-3)
  mark[data-color="grey"]
    background-color: map-get($grey, lighten-2)

  .cursor
    font-size: 0.8rem
    font-weight: normal
    line-height: 20px
    letter-spacing: normal

  span[data-mention-id]
    color: var(--v-anchor-base)

  blockquote, pre
    margin: 0.5rem 0

  h1, h2, h3
    margin-top: 1rem
    margin-bottom: 0.5rem

  h1:first-child, h2:first-child, h3:first-child
    margin-top: 0

  h1
    font-size: 2.125rem
    font-weight: 400
    letter-spacing: 0.015625rem

  h2
    font-size: 1.5rem
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

  img
    aspect-ratio: attr(width) / attr(height)
    max-width: 100%
    max-height: 600px
    width: auto
    height: auto

  ol, ul
    padding-left: 24px
    margin-bottom: .5rem

  ul
    list-style: disc

  ul[data-type="taskList"]
    list-style: none
    padding: 0

    // task item is
    // li
    //   label
    //     input
    //     span

    li
      display: flex
      align-items: center

      input[type="checkbox"]
        margin-right: 8px

      div
        display: inline-block
      p
        flex-shrink: 10000
        display: inline-block
        margin: 0

    li[data-due-on]:not([data-due-on=""])::after
      font-size: 10px
      color: #fff
      content: " 📅 " attr(data-due-on) ""
      border-radius: 8px
      background-color: var(--v-primary-base)
      margin-left: 8px
      padding: 2px 8px
      height: 16px
      display: flex
      align-items: center
      // border: 1px solid var(--v-primary-base)

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

    li[data-checked="true"]::before
      display: inline-block
      vertical-align: middle
      position: relative
      content: "✓"
      color: white
      text-align: center
      vertical-align: middle
      background-color: var(--v-primary-base)
      border-color: var(--v-primary-base)

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
    margin-bottom: 0

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
    border-left: 3px solid rgba(0,0,0,.1)
    // color: rgba(0,0,0,.8)
    padding-left: .8rem

  table
    table-layout: fixed
    width: 100%
    margin-bottom: 10px
    border-collapse: collapse

  table td
    padding: 4px 4px
    border: 1px solid #ddd

  thead td
    font-weight: bold

  table
    p
      margin-bottom: 0

    p:last-child
      margin-bottom: 0

</style>
