<script lang="coffee">
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
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
      EventBus.$emit 'currentComponent', { page: 'startDiscussionPage' }

      @discussion = Records.discussions.build
        title:       @$route.query.title
        groupId:     parseInt(@$route.query.group_id)

      if Session.isSignedIn()
        if @$route.params.key
          Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
            @discussion = discussion
        else if parseInt(@$route.query.group_id)
          Records.groups.findOrFetchById(parseInt(@$route.query.group_id))

</script>
<template lang="pug">
v-main
  v-container.start-discussion-page.max-width-800
    v-card
      discussion-form(:discussion='discussion' is-page)
</template>
