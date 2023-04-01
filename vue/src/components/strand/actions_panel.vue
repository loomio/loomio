<script lang="coffee">
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import AbilityService           from '@/shared/services/ability_service'
import PollCommonForm from '@/components/poll/common/form'
import PollCommonChooseTemplate from '@/components/poll/common/choose_template'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import { compact, snakeCase, camelCase, max, map } from 'lodash'

export default
  components: {PollCommonForm, PollCommonChooseTemplate}
  mixins: [ AuthModalMixin ]

  props:
    discussion: Object

  data: ->
    canAddComment: false
    currentAction: 'add-comment'
    newComment: null
    poll: null

  created: ->
    @watchRecords
      key: @discussion.id
      collections: ['groups', 'memberships']
      query: (store) =>
        @canAddComment = AbilityService.canAddComment(@discussion)
    @resetComment()

  methods:
    resetComment: ->
      @newComment = Records.comments.build
        bodyFormat: Session.defaultFormat()
        discussionId: @discussion.id
        authorId: Session.user().id

    setPoll: (poll) -> @poll = poll
    resetPoll: ->
      @poll = null
      @currentAction = 'add-comment'

    signIn:     -> @openAuthModal()
    isLoggedIn: -> Session.isSignedIn()

  watch:
    'discussion.id': 'reset'

  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

</script>

<template lang="pug">
section.actions-panel#add-comment(:key="discussion.id" :class="{'mt-2 px-2 px-sm-4': !discussion.newestFirst}")
  v-divider(aria-hidden="true")
  v-tabs.activity-panel__actions.mb-3(grow text v-model="currentAction")
    v-tabs-slider
    v-tab(href='#add-comment')
      span(v-t="'activity_card.add_comment'")
    v-tab.activity-panel__add-poll(href='#add-poll' v-if="canStartPoll")
      span(v-t="'poll_common_form.start_poll'")
  v-tabs-items(v-model="currentAction")
    v-tab-item(value="add-comment")
      .add-comment-panel
        comment-form(
          v-if='canAddComment'
          :comment="newComment"
          @comment-submitted="resetComment")
        .add-comment-panel__join-actions(v-if='!canAddComment')
          join-group-button(
            v-if='isLoggedIn()'
            :group='discussion.group()'
            :block='true')
          v-btn.add-comment-panel__sign-in-btn(v-t="'comment_form.sign_in'" @click='signIn()' v-if='!isLoggedIn()')
    v-tab-item(value="add-poll" v-if="canStartPoll")
      .poll-common-start-form.ma-3
        poll-common-form(
          v-if="poll"
          :poll="poll"
          @setPoll="setPoll"
          @saveSuccess="resetPoll")
        poll-common-choose-template(
          v-if="!poll"
          @setPoll="setPoll"
          :discussion="discussion"
          :group="discussion.group()")
</template>

<style lang="sass">
.add-comment-panel__sign-in-btn
	width: 100%
.add-comment-panel__join-actions
	button
		width: 100%

</style>
