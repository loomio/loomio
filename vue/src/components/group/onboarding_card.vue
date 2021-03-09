<script lang="coffee">
import Records       from '@/shared/services/records'
import openModal      from '@/shared/helpers/open_modal'
import Session       from '@/shared/services/session'
import {every, invokeMap} from 'lodash'
import { differenceInDays } from 'date-fns'
export default
  props:
    group: Object
  data: ->
    activities: []
  created: ->
    @activities = [
      icon: 'mdi-image'
      translate: "customize_group"
      complete:  => @group.description
      click:     =>
        openModal
          component: 'GroupForm'
          props:
            group: @group
    ,
      icon: 'mdi-account-multiple-plus'
      translate: "invite_people_in"
      complete:  => @group.membershipsCount > 1 or @group.invitationsCount > 0
      click:     =>
        openModal
          component: 'GroupInvitationForm'
          props:
            group: @group
    ,
      icon: 'mdi-comment-multiple'
      translate: "start_thread"
      complete:  => @group.discussionsCount > 1
      click:     =>
        openModal
          component: 'DiscussionForm'
          props:
            discussion: Records.discussions.build(groupId: @group.id)
    ]
  methods:
    translationFor: (key) ->
      "loomio_onboarding.group_progress_card.activities.#{key}"

    close: ->
      console.log "closing"
      Records.users.saveExperience("dismissProgressCard")

  computed:
    setupComplete: ->
      every invokeMap(@activities, 'complete')

    show: ->
      (differenceInDays(new Date, Session.user().createdAt) < 30) && # account is less than 30 days old
      @group.isParent() &&
      @group.adminsInclude(Session.user()) &&
      !Session.user().hasExperienced("dismissProgressCard")


</script>
<template lang="pug">
v-card.mb-4.group-progress-card(outlined flat v-if='show')
  v-card-title
    h4.headline.group-progress-card__title(v-if="!setupComplete" v-t="'loomio_onboarding.group_progress_card.title'")
    h4.headline.group-progress-card__title(v-if="setupComplete" v-t="'loomio_onboarding.group_progress_card.celebration_message'")
    v-spacer
    v-btn.group-progress-card__dismiss(@click="close" icon)
      v-icon mdi-close
  v-card-text
    v-list(dense).group-progress-card__list
      v-list-item.group-progress-card__list-item(@click='activity.click()' v-for='activity in activities' :key="activity.translate" :class="{'group-progress-card__complete': activity.complete()}")
        v-list-item-icon
          v-icon(color="primary") {{activity.icon}}
        v-list-item-content
          span.group-progress-card__activity-text(v-t="translationFor(activity.translate)")
    //- a.group-progress-card__learn-more(href='https://help.loomio.org/' target="_blank" v-t="'loomio_onboarding.group_progress_card.learn_more'")
</template>
