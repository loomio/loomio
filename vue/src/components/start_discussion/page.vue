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
    user: null

  mounted: ->
    @init()

  watch:
    '$route.query.group_id': 'init'
    '$route.params.key': 'init'

  methods:
    init: ->
      EventBus.$emit 'currentComponent', { page: 'startDiscussionPage', titleKey: 'discussion_form.new_discussion_title' }

      if Session.isSignedIn()
        if @$route.params.key
          Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
            @discussion = discussion.clone()
        else if parseInt(@$route.query.group_id)
          Records.groups.findOrFetchById(parseInt(@$route.query.group_id)).then =>
            @discussion = Records.discussions.build
              title: @$route.query.title
              groupId: parseInt(@$route.query.group_id)
        else if parseInt(@$route.query.user_id)
          Records.users.findOrFetchById(parseInt(@$route.query.user_id)).then (user) =>
            @user = user
            @discussion = Records.discussions.build
              title: @$route.query.title
              groupId: null
        else
          @discussion = Records.discussions.build
            title:       @$route.query.title

</script>
<template lang="pug">
v-main
  v-container.start-discussion-page.max-width-800
    v-card
      discussion-form(v-if="discussion" :discussion='discussion' is-page :key="discussion.id" :user="user")
</template>
