<script lang="js">
import { emojisByCategory, srcForEmoji } from '@/shared/helpers/emojis';
import { each, keys, pick } from 'lodash-es';

export default {
  props: {
    isPoll: Boolean,
    insert: {
      type: Function,
      required: true
    }
  },

  data() {
    return {
      search: '',
      showMore: false
    };
  },

  methods: {
    srcForEmoji
  },

  computed: {
    emojis() {
      if (this.showMore) {
        return emojisByCategory;
      } else {
        return pick(emojisByCategory, ['common', 'hands', 'expressions']);
      }
    }
  }
};

</script>

<template lang="pug">
v-sheet.emoji-picker.pa-2
  div(v-for='(emojiGroup, category) in emojis', :key='category')
    h5(v-t="'emoji_picker.'+category")
    div.emoji-picker__emojis
      span(v-for='(emoji, emojiName) in emojiGroup' :key='emojiName' @click='insert(emojiName, emoji)' :title='emojiName') {{ emoji }}
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
  font-size: 36px
  margin-bottom: 16px

  img, span
    width: 40px
    height: 40px
    cursor: pointer
    text-align: center
    display: block
    margin: 4px
</style>
