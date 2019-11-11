<script lang="coffee">
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import ModalService             from '@/shared/services/modal_service'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import { print } from '@/shared/helpers/window'
import { compact, snakeCase, camelCase, max, map } from 'lodash'
import ThreadActivityMixin from '@/mixins/thread_activity'

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

  methods:
    init: ->
      @newComment = Records.comments.build
        bodyFormat: "html"
        body: ""
        discussionId: @discussion.id
        authorId: Session.user().id

      @watchRecords
        key: @discussion.id
        collections: ['groups', 'memberships']
        query: (store) =>
          @canAddComment = AbilityService.canAddComment(@discussion)

    signIn:     -> @openAuthModal()
    isLoggedIn: -> Session.isSignedIn()

  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

</script>

<template lang="pug">
.actions-panel#add-comment
  v-divider(v-if="!discussion.newestFirst")
  v-tabs.activity-panel__actions.mb-3(grow icons-and-text v-model="currentAction")
    v-tab(href='#add-comment')
      span(v-t="'activity_card.comment'")
      v-icon mdi-comment
    v-tab.activity-panel__add-proposal(href='#add-proposal' v-if="canStartPoll")
      span(v-t="'poll_types.proposal'")
      v-icon mdi-thumbs-up-down
    v-tab.activity-panel__add-poll(href='#add-poll' v-if="canStartPoll")
      span(v-t="'poll_types.poll'")
      v-icon mdi-poll
    //- v-tab(href='#add-outcome')
    //-   span(v-t="'activity_card.add_outcome'")
    //-   v-icon mdi-lightbulb-on-outline
  v-tabs-items(v-model="currentAction")
    v-tab-item(value="add-comment")
      .add-comment-panel
        comment-form(v-if='canAddComment' :comment="newComment")
        .add-comment-panel__join-actions(v-if='!canAddComment')
          join-group-button(:group='discussion.group()' v-if='isLoggedIn()' :block='true')
          v-btn.add-comment-panel__sign-in-btn(v-t="'comment_form.sign_in'" @click='signIn()' v-if='!isLoggedIn()')
    v-tab-item(value="add-proposal" v-if="canStartPoll")
      poll-proposal-complete-form(:discussion="discussion")
    v-tab-item(value="add-poll" v-if="canStartPoll")
      poll-common-start-form(:discussion='discussion')
    //- v-tab-item(value="add-outcome")
  v-divider(v-if="discussion.newestFirst")

</template>
<style lang="sass">
.add-comment-panel__sign-in-btn
	width: 100%
.add-comment-panel__join-actions
	button
		width: 100%

</style>
