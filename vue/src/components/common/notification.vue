<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    notification: Object

  methods:
    membershipRequestActor: ->
      Records.users.build
        name:           @notification.translationValues.name
        avatarInitials: @notification.translationValues.name.toString().split(' ').map((n) -> n[0]).join('')
        avatarKind:     'initials'

  computed:
    actor: ->
      @membershipRequestActor() || @notification.actor()

    contentFor: ->
      @$t("notifications.#{@notification.kind}", @notification.translationValues)

</script>

<template lang="pug">
v-list-tile.notification(:to="notification.url", :class="{'lmo-active': !notification.viewed}")
  v-list-tile-avatar
    user-avatar(v-if="actor", :user="actor", size="medium")
    //- .thread-item__proposal-icon{ng-if: "!actor()"}
  v-list-tile-content
    span(v-html="contentFor")
    time-ago(:date="notification.createdAt")
</template>
