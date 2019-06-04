<script lang="coffee">
import { capitalize } from 'lodash'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'

export default
  props:
    model: Object

  data: ->
    search: null
    closeEmojiMenu: false

  methods:
    insert: (emoji) ->
      params =
        reactableType: capitalize(@model.constructor.singular)
        reactableId: @model.id
        userId: Session.user().id

      reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
      reaction.reaction = ":#{emoji}:"
      reaction.save()
      @closeEmojiMenu = true


</script>

<template lang="pug">
v-menu.reactions-input(:close-on-content-click="true" v-model="closeEmojiMenu" lazy)
  template(v-slot:activator="{on}")
    v-btn.emoji-picker__toggle(flat icon v-on="on")
      v-icon mdi-emoticon-outline
  emoji-picker(:insert="insert")
  //- md-tooltip{md-delay: "500"}
  //-   %span{translate: "reactions_input.add_your_reaction"}
</template>

<style lang="scss">
.reactions-input {
  display: flex;
  align-items: center;
}
</style>
