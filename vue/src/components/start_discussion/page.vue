<script lang="coffee">
import Records       from '@/shared/services/records'
import ModalService  from '@/shared/services/modal_service'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'

export default
  data: ->
    discussion: null
    isDisabled: false
  created: ->
    @init()
  methods:
    init: ->
      EventBus.$emit 'currentComponent', { page: 'startDiscussionPage', skipScroll: true }
      @discussion = Records.discussions.build
        title:       @$route.query.title
        groupId:     parseInt(@$route.query.group_id)

      Records.groups.findOrFetch(@$route.params.group_id).then =>
        # applyDiscussionStartSequence @,
        #   emitter: @
        #   afterSaveComplete: (event) ->
        #     ModalService.open 'AnnouncementModal', announcement: ->
        #       Records.announcements.buildFromModel(event)
</script>
<template lang="pug">
v-content
  v-container.start-discussion-page.max-width-1024
    h2.headline(v-t="'discussion_form.new_discussion_title'")
    .discussion-start-discussion
      discussion-form(:discussion='discussion')
</template>
