<script lang="coffee">
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import AbilityService           from '@/shared/services/ability_service'
import PollCommonForm from '@/components/poll/common/form'
import PollCommonChooseTemplateWrapper from '@/components/poll/common/choose_template_wrapper'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import { compact, snakeCase, camelCase, max, map } from 'lodash'

export default
  components: {PollCommonForm, PollCommonChooseTemplateWrapper}
  mixins: [ AuthModalMixin ]

  props:
    discussion: Object

  data: ->
    canAddComment: false
    currentAction: 'add-comment'
    newComment: null
    poll: null
    showDecisionBadge: false

  created: ->
    @resetBadge()
    
    @watchRecords
      key: @discussion.id
      collections: ['groups', 'memberships', 'polls']
      query: (store) =>
        @canAddComment = AbilityService.canAddComment(@discussion)
        @resetBadge()
    @resetComment()

  methods:
    resetBadge: ->
      if @canStartPoll && @discussion.discussionTemplateKeyOrId() && @discussion.activePolls().length == 0
        @showDecisionBadge = true

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
    'discussion.id': -> 
      @resetComment()
      @resetPoll()

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
      span(v-t="'thread_context.add_comment'")
    v-tab.activity-panel__add-poll(href='#add-poll' v-if="canStartPoll")
      //- span(v-t="'poll_common_form.start_poll'")
      span(v-t="'poll_common.decision'")
      v-badge(v-if="showDecisionBadge" inline dot)
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
      .poll-common-start-form
        poll-common-form(
          v-if="poll"
          :poll="poll"
          @setPoll="setPoll"
          @saveSuccess="resetPoll")
        poll-common-choose-template-wrapper(
          v-if="!poll"
          @setPoll="setPoll"
          :discussion="discussion"
          :group="discussion.group()")
</template>

<style lang="sass">
#add-comment .v-window
  overflow: visible
  
.add-comment-panel__sign-in-btn
  width: 100%
.add-comment-panel__join-actions
  button
    width: 100%

</style>
