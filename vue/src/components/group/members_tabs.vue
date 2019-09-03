<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
export default
  mixins: [AnnouncementModalMixin]
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
  methods:
    invite: ->
      @openAnnouncementModal(Records.announcements.buildFromModel(@group.targetModel()))
  computed:
    canAddMembers: ->
      AbilityService.canAddMembers(@group.targetModel().group() || @group) && !@pending

    onlyOneAdminWithMultipleMembers: ->
      (@group.adminMembershipsCount < 2) && ((@group.membershipsCount - @group.adminMembershipsCount) > 0)

</script>
<template lang="pug">
.members-tabs
  v-alert(v-model="onlyOneAdminWithMultipleMembers" color="primary" type="warning")
    template(slot="default")
      span(v-t="'memberships_page.only_one_admin'")
  v-toolbar(flat color="transparent")
    v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers' @click="invite()" v-t="'common.action.invite'")
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
