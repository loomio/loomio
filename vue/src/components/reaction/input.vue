<script lang="coffee">
import { capitalize } from 'lodash-es'
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
v-menu.reactions-input(:close-on-content-click="true" v-model="closeEmojiMenu")
  template(v-slot:activator="{on: menu}")
    v-btn.emoji-picker__toggle.action-button(small text v-on="{ ...menu }" v-t="'action_dock.react'")
  emoji-picker(:insert="insert")
</template>

<style lang="sass">
.reactions-input
	display: flex
	align-items: center

</style>
