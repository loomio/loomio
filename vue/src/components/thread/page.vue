<script lang="coffee">
import Records           from '@/shared/services/records'
import Session           from '@/shared/services/session'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import AuthModalMixin from '@/mixins/auth_modal'
import { first, last } from 'lodash'

export default
  mixins: [AuthModalMixin]

  data: ->
    discussion: null
    threadPercentage: 0
    position: 0
    group: null
    discussionFetchError: null

  created: ->
    EventBus.$on 'visibleSlots', (slots) =>
      return unless @discussion
      unless slots.length == 0
        @position = if @discussion.newestFirst
          last(slots) || @discussion.createdEvent().childCount
        else
          last(slots) || 1
        @threadPercentage = @position / @discussion.createdEvent().childCount * 100

  mounted: -> @init()

  watch:
    '$route.params.key': 'init'
    '$route.params.comment_id': 'init'

  methods:
    openThreadNav: -> EventBus.$emit('toggleThreadNav')

    init: ->
      Records.discussions.findOrFetchById(@$route.params.key)
      .then (discussion) =>
        @discussion = discussion
        @group = @discussion.group()
        EventBus.$emit 'currentComponent',
          page: 'threadPage'
          discussion: @discussion
          group: @group
          title: @discussion.title
      .catch (error) =>
        @discussionFetchError = error
      .finally =>
        Records.samlProviders.fetchByDiscussionId(@$route.params.key)
        .then (obj) =>
          if !Session.isSignedIn() && Session.pendingInvitation()
            @openAuthModal()
          else
            window.location = "/saml_providers/#{obj.saml_provider_id}/auth" if !Session.user() || !Session.user().membershipFor(@group)
        .catch (error) =>
          EventBus.$emit 'pageError', @discussionFetchError if @discussionFetchError

</script>

<template lang="pug">
.thread-page
  v-content
    loading(:until="discussion")
      v-container.thread-page.max-width-800(v-if="discussion")
        thread-current-poll-banner(:discussion="discussion")
        discussion-fork-actions(:discussion='discussion' v-show='discussion.isForking' :key="'fork-actions'+ discussion.id")
        thread-card(:discussion='discussion' :key="discussion.id")
        v-btn.thread-page__open-thread-nav(fab fixed bottom right @click="openThreadNav()")
          v-progress-circular(color="accent" :value="threadPercentage")

  router-view(name="nav")
</template>
