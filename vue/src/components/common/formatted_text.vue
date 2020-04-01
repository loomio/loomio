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
div.lmo-markdown-wrapper.body-2.text--primary
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
  span.mention
    color: var(--v-anchor-base)

  blockquote, h1, h2, h3, ol, p, pre, ul
    margin: 1rem 0

  blockquote:first-child, h1:first-child, h2:first-child, h3:first-child, ol:first-child, p:first-child, pre:first-child, ul:first-child
    margin-top: 0

  blockquote:last-child, h1:last-child, h2:last-child, h3:last-child, ol:last-child, p:last-child, pre:last-child, ul:last-child
    margin-bottom: 0

  h1
    line-height: 2.75rem
    font-size: 1.6rem
    font-weight: 400
    letter-spacing: .0125em
    margin-top: 0.5em

  h2
    line-height: 2rem
    font-size: 1.2rem
    font-weight: 400
    letter-spacing: .0125em
    margin-bottom: 0.75em

  h3
    line-height: 2.5rem
    font-size: 1rem
    font-weight: 700
    letter-spacing: .009375em

  p
    margin-bottom: 12px

  p:last-child
    margin-bottom: 4px

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
    margin-bottom: 16px
    ul
      margin-bottom: 0

  ul
    list-style: disc

  ol
    list-style: decimal

  li p
    margin-bottom: 0

  pre
    // padding: .7rem 1rem
    // border-radius: 5px
    // background: #000
    // color: #fff
    // font-size: .8rem
    overflow-x: auto
    // overflow: auto
    // padding: 0
    // font-family: 'Roboto mono', monospace, monospace
    // white-space: pre-wrap

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

  table td
    padding: 6px 13px
    border: 1px solid #ddd

  thead td
    font-weight: bold

</style>
