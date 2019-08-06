<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
export default
  mixins: [AnnouncementModalMixin]
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
  methods:
    canAddMembers: ->
      AbilityService.canAddMembers(@group.targetModel().group() || @group) && !@pending

    invite: ->
      @openAnnouncementModal(Records.announcements.buildFromModel(@group.targetModel()))
</script>
<template lang="pug">
.members-tabs
  v-toolbar(flat color="transparent")
    v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers()' @click="invite()" v-t="'common.action.invite'")
    space
    shareable-link-modal(:group="group")

  v-card
    v-tabs(fixed-tabs)
      v-tab(:to="urlFor(group, 'members')" v-t="'members_panel.directory'")
      v-tab(:to="urlFor(group, 'members/invitations')" v-t="'members_panel.invitations'")
      v-tab(:to="urlFor(group, 'members/requests')" v-t="'members_panel.requests'")
    v-divider
    router-view
</template>
