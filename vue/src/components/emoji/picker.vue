<script lang="coffee">

import { emojisByCategory, srcForEmoji } from '@/shared/helpers/emojis'
import { each, keys, pick } from 'lodash'

export default
  props:
    isPoll: Boolean
    insert:
      type: Function
      required: true

  data: ->
    search: ''
    showMore: false

  methods:
    srcForEmoji: srcForEmoji
    bannedEmoji: (name) ->
      @isPoll && ['thumbsup', 'thumbs_up', 'thumbsdown', 'thumbs_down', 'hand'].includes(name)

  computed:
    emojis: ->
      if @showMore
        emojisByCategory
      else
        pick(emojisByCategory, (@isPoll && ['common', 'expressions']) || ['common', 'hands', 'expressions'])

</script>

<template lang="pug">
v-sheet.emoji-picker.pa-2
  div(v-for='(emojiGroup, category) in emojis', :key='category')
    h5(v-t="'emoji_picker.'+category")
    div.emoji-picker__emojis
      span(v-for='(emoji, emojiName) in emojiGroup' v-if="!bannedEmoji(emojiName)" :key='emojiName' @click='insert(emojiName, emoji)' :title='emojiName') {{ emoji }}
  .d-flex.justify-center.pb-2
    v-btn(v-if="!showMore" x-small @click.stop="showMore = true" v-t="'common.action.show_more'")
    v-btn(v-if="showMore" x-small @click.stop="showMore = false" v-t="'common.action.show_fewer'")
</template>

<style lang="sass">
.emoji-picker
  max-width: 240px
  max-height: 400px
  overflow-y: auto
  h5
    font-weight: normal
    // text-align: center

.emoji-picker__emojis
  display: flex
  flex-direction: row
  flex-wrap: wrap
  font-size: 48px
  margin-bottom: 16px

  img, span
    width: 48px
    height: 48px
    cursor: pointer
    text-align: center
    display: block
    margin: 4px
</style>
