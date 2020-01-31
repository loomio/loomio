<script lang="coffee">
import Records       from '@/shared/services/records'
import ModalService  from '@/shared/services/modal_service'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'

export default
  data: ->
    discussion: null
    isDisabled: false
    group: null

  mounted: ->
    @init()

  methods:
    init: ->
      EventBus.$emit 'currentComponent', { page: 'startDiscussionPage', skipScroll: true }

      Records.groups.findOrFetchById(parseInt(@$route.query.group_id)).then (group) =>
        @group = group
      .finally =>
        @discussion = Records.discussions.build
          title:       @$route.query.title
          groupId:     parseInt(@$route.query.group_id)

</script>
<template lang="pug">
v-content
  v-container.start-discussion-page.max-width-1024
    h2.headline(v-t="'discussion_form.new_discussion_title'")
    .discussion-start-discussion
      discussion-form(v-if="discussion" :discussion='discussion')
</template>
