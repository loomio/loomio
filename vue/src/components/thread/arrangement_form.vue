<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { submitDiscussion } from '@/shared/helpers/form'
import { map, sortBy, filter } from 'lodash'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'

export default
  mixins: [AnnouncementModalMixin]
  props:
    discussion: Object
    close: Function

  mounted: ->
    @submit = submitDiscussion @, @discussion,
      successCallback: (data) => @close()

</script>

<template lang="pug">
v-card.discussion-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline Rearrange thread layout
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  .pa-4
    v-subheader Sort
    v-radio-group(v-model="discussion.reverseOrder")
      v-radio(:value="false")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.earliest'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.earliest_description'")

      v-radio(:value="true")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.latest'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.latest_description'")

    v-subheader Replies
    v-radio-group(v-model="discussion.maxDepth")
      v-radio(:value="1")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.linear'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.linear_description'")
      v-radio(:value="2")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.nested_once'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.nested_once_description'")
      v-radio(:value="3")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.nested_twice'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.nested_twice_description'")
  v-card-actions
    v-spacer
    v-btn(color="primary" @click="submit()" v-t="'common.action.save'")
</template>
