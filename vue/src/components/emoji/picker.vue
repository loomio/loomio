<script lang="coffee">

import { emojisByCategory } from '@/shared/helpers/emojis'
import { each, keys } from 'lodash'

export default
  props:
    insert:
      type: Function
      required: true

  data: ->
    search: ''

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
    div.emoji-picker__emojis
      span(v-for='(emoji, emojiName) in emojiGroup', :key='emojiName', @click='insert(emojiName, emoji)', :title='emojiName') {{ emoji }}
</template>

<style lang="scss">
.emoji-picker {
  padding: 4px;
  background-color: #fff;
  max-width: 200px;
  max-height: 400px;
  overflow-y: auto;
}
.emoji-picker__emojis {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  font-size: 20px;

  span {
    width: 24px;
    height: 24px;
    cursor: pointer;
    text-align: center;
    display: block;
    border-radius: 50%;
  }
}
</style>
