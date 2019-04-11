<script lang="coffee">
import Records from '@/shared/services/records'
import { applyDiscussionStartSequence } from '@/shared/helpers/apply'

export default
  props:
    discussion: Object
    close: Function
  data: ->
    announcement: {}
  created: ->
    applyDiscussionStartSequence @,
      afterSaveComplete: (event) =>
        @announcement = Records.announcements.buildFromModel(event)
</script>

<template lang="pug">
v-card.discussion-modal
  // <div v-show="isDisabled" class="lmo-disabled-form"></div>
  //- v-toolbar(flat)
  //-   v-toolbar-avatar
  //-     v-icon mdi-forum
  //-   v-toolbar-title
  //-     span(v-t="'discussion_form.new_discussion_title'", v-if="currentStep == 'save' && !discussion.isForking()")
  //-     span(v-t="'discussion_form.fork_discussion_title'", v-if="currentStep == 'save' && discussion.isForking()")
  //-     span(v-t="'announcement.form.discussion_announced.title'", v-if="currentStep == 'announce'")
  //-   v-spacer
  //-   v-toolbar-items
  //-     dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      v-flex
        .headline(v-t="'discussion_form.new_discussion_title'")
      v-flex(shrink)
        dismiss-modal-button(aria-hidden='true', :close='close')

  v-card-text.md-body-1.lmo-slide-animation
    discussion-form(:discussion='discussion', v-if="currentStep == 'save'")
    // <announcement_form :announcement="announcement" v-if="currentStep == announce"></announcement_form>
  v-card-actions
    discussion-form-actions(:discussion='discussion', :close='close', v-if="currentStep == 'save'")
    // <announcement_form_actions announcement="announcement" v-if="currentStep == announce"></announcement_form_actions>
</template>
