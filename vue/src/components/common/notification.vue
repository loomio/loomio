<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    notification: Object
    unread: Boolean
  methods:
    membershipRequestActor: ->
      Records.users.build
        name:           @notification.translationValues.name
        avatarInitials: @notification.translationValues.name.toString().split(' ').map((n) -> n[0]).join('')
        avatarKind:     'initials'

  computed:
    actor: ->
      @notification.actor() || @membershipRequestActor()

    contentFor: ->
      @$t("notifications.#{@notification.kind}", @notification.translationValues)

</script>

<template lang="pug">
router-link(:to="'/'+notification.url")
  v-layout.notification.body-2(align-center :class="{'notification--unread': unread}")
    .notification__avatar.ma-2
      user-avatar(v-if="actor", :user="actor", size="thirtysix")
      //- .thread-item__proposal-icon{ng-if: "!actor()"}
    .notification__content.text--primary.py-2.px-1
      span(v-html="contentFor")
      space
      span(aria-hidden='true') ·
      space
      time-ago(:date="notification.createdAt")
</template>

<style lang="sass">
.notification:hover
  background-color: var(--v-accent-lighten5)

.notification--unread
  background-color: var(--v-info-lighten5)

</style>
