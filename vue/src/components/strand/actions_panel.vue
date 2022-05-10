<script lang="coffee">
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import { compact, snakeCase, camelCase, max, map } from 'lodash'

export default
  mixins: [ AuthModalMixin ]

  props:
    discussion: Object

  data: ->
    canAddComment: false
    currentAction: 'add-comment'
    newComment: null

  created: ->
    @init()
    EventBus.$on 'pollSaved', =>
      @currentAction = 'add-comment'

  beforeDestroy: ->
    EventBus.$off 'pollSaved'

  methods:
    init: ->
      @watchRecords
        key: @discussion.id
        collections: ['groups', 'memberships']
        query: (store) =>
          @canAddComment = AbilityService.canAddComment(@discussion)
      @reset()

    reset: ->
      @newComment = Records.comments.build
        bodyFormat: Session.defaultFormat()
        discussionId: @discussion.id
        authorId: Session.user().id

    signIn:     -> @openAuthModal()
    isLoggedIn: -> Session.isSignedIn()

  watch:
    'discussion.id': 'reset'

  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

</script>

<template lang="pug">
section.actions-panel#add-comment(:aria-label="$t('activity_card.aria_label')")
  v-divider(aria-hidden="true")
  v-tabs.activity-panel__actions.mb-3(grow text v-model="currentAction" show-arrows)
    v-tabs-slider
    v-tab(href='#add-comment')
      span(v-t="'activity_card.comment'")
    v-tab.activity-panel__add-poll(href='#add-poll' v-if="canStartPoll")
      span(v-t="'poll_types.poll'")
  v-tabs-items(v-model="currentAction")
    v-tab-item(value="add-comment")
      .add-comment-panel
        comment-form(v-if='canAddComment' :comment="newComment" @comment-submitted="reset()")
        .add-comment-panel__join-actions(v-if='!canAddComment')
          join-group-button(:group='discussion.group()' v-if='isLoggedIn()' :block='true')
          v-btn.add-comment-panel__sign-in-btn(v-t="'comment_form.sign_in'" @click='signIn()' v-if='!isLoggedIn()')
    v-tab-item(value="add-poll" v-if="canStartPoll")
      poll-common-start-form(:discussion='discussion' :group="discussion.group()")

</template>
<style lang="sass">
.add-comment-panel__sign-in-btn
	width: 100%
.add-comment-panel__join-actions
	button
		width: 100%

</style>
