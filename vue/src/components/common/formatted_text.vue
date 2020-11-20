<script lang="coffee">
import { emojiReplaceText } from '@/shared/helpers/emojis.coffee'

export default
  props:
    model:
      type: Object
      required: true
    column:
      type: String
      required: true
  computed:
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
img.emoji
  width: 1.4em !important
  vertical-align: top
  margin: 0 .05em

.lmo-markdown-wrapper
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

  .cursor
    font-size: 0.8rem
    font-weight: normal
    line-height: 20px
    letter-spacing: normal

  span.mention
    color: var(--v-anchor-base)

  blockquote, pre
    margin: 0.5rem 0

  h1, h2, h3
    margin-top: 1rem

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
    font-size: 1.25rem
    font-weight: 500
    letter-spacing: 0.009375rem

  strong
    font-weight: 700

  hr
    border: 0
    border-bottom: 2px solid rgba(0,0,0,0.1)
    margin: 16px 0

  word-wrap: break-word

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
    // padding: 0 .4rem
    // border-radius: 5px
    // font-size: .8rem
    // font-weight: 700
    background: rgba(0, 0, 0, .1)
    // color: rgba(0, 0, 0, .8)

  // pre:last-of-type
  //   padding-bottom: 16px

  // code
  //   background-color: transparent
  //   color: rgba(#000, 0.88)
  //   box-shadow: none
  //   border-radius: 0
  //   white-space: normal
  //   font-weight: 400
  //   font-family: 'Roboto mono', monospace, monospace

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
