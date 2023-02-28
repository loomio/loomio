<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'
import { startCase } from 'lodash'

export default
  props:
    eventId: Number

  data: ->
    show: false
    newComment: null

  created: ->
    EventBus.$on 'toggle-reply', (eventable, eventId) =>
      if eventId == @eventId
        if @show
          if RescueUnsavedEditsService.okToLeave(@newComment)
            @show = false
        else
          body = "" 
          op = eventable.author()
          if op.id != Session.user().id
            body = "<p><span class=\"mention\" data-mention-id=\"#{op.username}\" label=\"#{op.name}\">@#{op.name}</span></p>"

          @newComment = Records.comments.build
            bodyFormat: "html"
            body: body
            discussionId: eventable.discussion().id
            authorId: Session.user().id
            parentId: eventable.id
            parentType: startCase(eventable.constructor.singular)
          @show = true

  destroyed: ->
    # kill listener

</script>

<template lang="pug">
.reply-form(v-if="show")
  //- p reply formwrapper {{eventable.constructor.singular}}

  comment-form(
    :comment="newComment"
    avatar-size="36"
    @comment-submitted="show= false"
    @cancel-reply="show = false"
    autofocus)


</template>
