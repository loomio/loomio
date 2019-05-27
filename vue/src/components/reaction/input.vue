<script lang="coffee">
import { Picker } from 'emoji-mart-vue'
import { capitalize } from 'lodash'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'

export default
  props:
    model: Object

  components:
    Picker: Picker

  data: ->
    closeEmojiMenu: false
    recentEmojis: 'thumbsup thumbsdown laughing wink sunglasses neutral_face sleeping relieved confused astonished confounded disappointed worried cry weary scream angry v ok_hand wave clap raised_hands pray heart'.split(" ")

  methods:
    emojiPicked: (emoji) ->
      params =
        reactableType: capitalize(@model.constructor.singular)
        reactableId: @model.id
        userId: Session.user().id

      reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
      reaction.reaction = emoji.colons
      reaction.save()
      @closeEmojiMenu = true


</script>

<template lang="pug">
v-menu(:close-on-content-click="true" v-model="closeEmojiMenu").reactions-input
  template(v-slot:activator="{on}")
    v-btn.emoji-picker__toggle(v-on="on" flat icon)
      v-icon mdi-emoticon-outline
  picker.emoji-picker(@select="emojiPicked" emoji="point_up" :recent="recentEmojis" :title="$t('emoji_picker.search')" :native="true" set="apple")

  //- md-tooltip{md-delay: "500"}
  //-   %span{translate: "reactions_input.add_your_reaction"}
</template>

<style lang="scss">
.reactions-input {
  display: flex;
  align-items: center;
}
</style>
