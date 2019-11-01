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
    handleSearchQueryChange: (val) ->
      @$router.replace({ query: { q: val } })
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
  v-layout.py-2(algin-center)
    v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers' @click="invite()" v-t="'invitation_form.invite_people'")
    shareable-link-modal.mr-2(:group="group")
    v-text-field(dense clearable hide-details solo @change="handleSearchQueryChange" :placeholder="$t('navbar.search_members', {name: group.name})" append-icon="mdi-magnify")
  v-card
    v-tabs(fixed-tabs)
      v-tab.group-page__directory-tab(:to="urlFor(group, 'members')" v-t="'members_panel.directory'")
      v-tab.group-page__invitations-tab(:to="urlFor(group, 'members/invitations')" v-t="'members_panel.invitations'")
      v-tab.group-page__requests-tab(:to="urlFor(group, 'members/requests')" v-t="'members_panel.requests'")
    v-divider
    router-view
</template>
