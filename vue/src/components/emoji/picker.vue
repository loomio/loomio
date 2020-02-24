<script lang="coffee">

import { emojisByCategory, srcForEmoji, emojiSupported } from '@/shared/helpers/emojis'
import { each, keys } from 'lodash'

export default
  props:
    insert:
      type: Function
      required: true

  data: ->
    search: ''
    emojiSupported: emojiSupported

  methods:
    srcForEmoji: srcForEmoji

  computed:
    emojis: ->
      if @search
        obj = {}
        each keys(emojisByCategory), (category) =>
          obj[category] = {}
          each keys(emojisByCategory[category]), (emoji) =>
            if new RegExp(".*#{@search}.*").test(emoji)
              obj[category][emoji] = emojisByCategory[category][emoji]

          if keys(obj[category]).length == 0
            delete obj[category]
        obj
      else
        emojisByCategory

</script>

<template lang="pug">
.emoji-picker
  div(v-for='(emojiGroup, category) in emojis', :key='category')
    h5(v-t="'emoji_picker.'+category")
    div.emoji-picker__emojis(v-if="emojiSupported")
      span(v-for='(emoji, emojiName) in emojiGroup' :key='emojiName' @click='insert(emojiName, emoji)' :title='emojiName') {{ emoji }}
    div.emoji-picker__emojis(v-else)
      img(v-for='(emoji, emojiName) in emojiGroup' :key='emojiName' @click='insert(emojiName, emoji)' :alt="emojiName" :src="srcForEmoji(emoji)")
</template>

<style lang="sass">
.emoji-picker
  padding: 4px
  background-color: #fff
  max-width: 232px
  max-height: 400px
  overflow-y: auto

.emoji-picker__emojis
  display: flex
  flex-direction: row
  flex-wrap: wrap
  font-size: 48px

  img, span
    width: 48px
    height: 48px
    cursor: pointer
    text-align: center
    display: block
    margin: 4px
</style>
