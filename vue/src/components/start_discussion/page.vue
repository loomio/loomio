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

      if Session.isSignedIn()
        if @$route.params.key
          Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
            @group = discussion.group()
            @discussion = discussion
        else
          Records.groups.findOrFetchById(parseInt(@$route.query.group_id)).then (group) =>
            @group = group
            @discussion = Records.discussions.build
              title:       @$route.query.title
              groupId:     parseInt(@$route.query.group_id)

</script>
<template lang="pug">
v-main
  v-container.start-discussion-page.max-width-1024
    v-card
      discussion-form(v-if="group && discussion" :discussion='discussion' is-page)
</template>
