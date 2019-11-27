<script lang="coffee">
import Records from '@/shared/services/records'
import { colonToUnicode } from '@/shared/helpers/emojis'
import AppConfig from '@/shared/services/app_config'

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
    url: ->
      return '/' unless @notification.url
      if @notification.kind == 'membership_requested'
        "/"+@notification.url.split('/')[1]+"/members/requests"
      else if @notification.url.startsWith(AppConfig.baseUrl)
        "/" +@notification.url.replace(AppConfig.baseUrl, '')
      else
        "/"+@notification.url

    path: ->
      if @notification.kind == "reaction_created"
        "notifications.reaction_created_vue"
      else
        "notifications.#{@notification.kind}"

    args: ->
      name: @notification.translationValues.name
      reaction: colonToUnicode(@notification.translationValues.reaction) if @notification.kind == "reaction_created"
      title: @notification.translationValues.title
      poll_type: @notification.translationValues.poll_type
      model: @notification.translationValues.model

    actor: ->
      @notification.actor() || @membershipRequestActor()

</script>

<template lang="pug">
router-link(:to="url")
  v-layout.notification.body-2(align-center :class="{'notification--unread': unread}")
    .notification__avatar.ma-2
      user-avatar(v-if="actor", :user="actor", size="thirtysix")
    .notification__content.text--primary.py-2.px-1
      span(v-html="$t(path, args)")
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
