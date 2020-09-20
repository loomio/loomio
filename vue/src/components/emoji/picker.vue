<script lang="coffee">

import { emojisByCategory, srcForEmoji, emojiSupported } from '@/shared/helpers/emojis'
import { each, keys, pick } from 'lodash'

export default
  props:
    insert:
      type: Function
      required: true

  data: ->
    search: ''
    emojiSupported: emojiSupported
    showMore: false

  methods:
    srcForEmoji: srcForEmoji

  computed:
    emojis: ->
      if @showMore
        emojisByCategory
      else
        pick(emojisByCategory, ['common', 'hands', 'expressions'])

</script>

<template lang="pug">
.emoji-picker
  div(v-for='(emojiGroup, category) in emojis', :key='category')
    h5(v-t="'emoji_picker.'+category")
    div.emoji-picker__emojis(v-if="emojiSupported")
      span(v-for='(emoji, emojiName) in emojiGroup' :key='emojiName' @click='insert(emojiName, emoji)' :title='emojiName') {{ emoji }}
    div.emoji-picker__emojis(v-else)
      img(v-for='(emoji, emojiName) in emojiGroup' :key='emojiName' @click='insert(emojiName, emoji)' :alt="emojiName" :src="srcForEmoji(emoji)")
  .d-flex.justify-center.pb-2
    v-btn(v-if="!showMore" x-small @click.stop="showMore = true" v-t="'common.action.show_more'")
    v-btn(v-if="showMore" x-small @click.stop="showMore = false" v-t="'common.action.show_fewer'")
</template>

<style lang="sass">
.emoji-picker
  padding: 8px
  background-color: #fff
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
