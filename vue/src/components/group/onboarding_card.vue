<script lang="coffee">
import Records       from '@/shared/services/records'
import openModal      from '@/shared/helpers/open_modal'
import Session       from '@/shared/services/session'
export default
  props:
    group: Object
  data: ->
    activities: []
  created: ->
    @activities = [
      translate: "set_description"
      complete:  => @group.description
      click:     =>
        openModal
          component: 'GroupForm'
          props:
            group: @group
    ,
      translate: "set_logo"
      complete:  => @group.logoUrl() != '/theme/icon.png'
      click:     =>
        openModal
          component: 'GroupForm'
          props:
            group: @group
    ,
      translate: "set_cover_photo"
      complete:  => @group.hasCustomCover
      click:     =>
        openModal
          component: 'GroupForm'
          props:
            group: @group
    ,
      translate: "invite_people_in"
      complete:  => @group.membershipsCount > 1 or @group.invitationsCount > 0
      click:     =>
        openModal
          component: 'AnnouncementForm'
          props:
            announcement: Records.announcements.buildFromModel(@group)
    ,
      translate: "start_thread"
      complete:  => @group.discussionsCount > 2
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
      Records.memberships.saveExperience("dismissProgressCard", Session.user().membershipFor(@group))
    setupComplete: ->
      _.every _.invokeMap(@activities, 'complete')

  computed:
    show: ->
      @group.isParent() &&
      Session.user().isAdminOf(@group) &&
      !Session.user().hasExperienced("dismissProgressCard", @group)


</script>
<template lang="pug">
v-card.group-progress-card(outlined flat v-if='show')
  v-card-title
    h2.group-progress-card__title.lmo-card-heading(v-t="'loomio_onboarding.group_progress_card.title'")
    v-spacer
    dismiss-modal-button.group-progress-card__dismiss(:close="close")
  v-card-text
    v-list(dense).group-progress-card__list
      v-list-item.group-progress-card__list-item(@click='activity.click()' v-for='activity in activities' :key="activity.translate" :class="{'group-progress-card__complete': activity.complete()}")
        v-list-item-icon
          v-icon(v-if='activity.complete()') mdi-checkbox-marked
          v-icon(v-if='!activity.complete()') mdi-checkbox-blank-outline
        v-list-item-content
          span.group-progress-card__activity-text(v-t="translationFor(activity.translate)")
    .group-progress-card__celebration-message(v-if='setupComplete()')
      span 🎉
      strong(v-t="'loomio_onboarding.group_progress_card.celebration_message'")
      a(@click='close()' v-t="'loomio_onboarding.group_progress_card.dismiss_this_card'")
    a.group-progress-card__learn-more(href='https://help.loomio.org/' target="_blank" v-t="'loomio_onboarding.group_progress_card.learn_more'")
</template>
