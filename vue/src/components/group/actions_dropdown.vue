<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ConfirmModalMixin from '@/mixins/confirm_modal'
import GroupModalMixin from '@/mixins/group_modal'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import Flash from '@/shared/services/flash'
import WatchRecords    from '@/mixins/watch_records'
export default
  mixins: [ WatchRecords, ConfirmModalMixin, GroupModalMixin, ChangeVolumeModalMixin]
  props:
    group: Object

  data: ->
    canBecomeCoordinator: false
    canSeeGroupActions: false
    canExportData: false

  created: ->
    @watchRecords
      collections: ['memberships']
      query: =>
        membership = @group.membershipFor(Session.user())
        @canBecomeCoordinator = membership && membership.admin == false &&
          (membership.group().adminMembershipsCount == 0 or
          Session.user().isAdminOf(membership.group().parent()))

        @canSeeGroupActions = @canExportData = Session.user().isMemberOf(@group)

  methods:
    becomeCoordinator: ->
      membership = @group.membershipFor(Session.user())
      Records.memberships.makeAdmin(membership).then ->
        Flash.success "memberships_page.messages.make_admin_success", name: Session.user().name

    openChangeVolumeForm: ->
      @openChangeVolumeModal(@group.membershipFor(Session.user()))

    editGroup: ->
      @openEditGroupModal(@group)

    addSubgroup: ->
      @openStartSubgroupModal(@group)

    openGroupExportModal: ->
      @openConfirmModal(@groupExportModalConfirmOpts)

    openLeaveGroupModal: ->
      @openConfirmModal(@leaveGroupModalConfirmOpts)

    openArchiveGroupModal: ->
      @openConfirmModal(@archiveGroupModalConfirmOpts)

  computed:

    groupExportModalConfirmOpts: ->
      submit: @group.export
      text:
        title:    'group_export_modal.title'
        helptext: 'group_export_modal.body'
        submit:   'group_export_modal.submit'
        flash:    'group_export_modal.flash'

    leaveGroupModalConfirmOpts: ->
      submit:  Session.user().membershipFor(@group).destroy
      text:
        title:    'leave_group_form.title'
        helptext: 'leave_group_form.question'
        confirm:  'leave_group_form.submit'
        flash:    'group_page.messages.leave_group_success'
      redirect: '/dashboard'

    archiveGroupModalConfirmOpts: ->
      submit:     @group.archive
      text:
        title:    'archive_group_form.title'
        helptext: 'archive_group_form.question'
        flash:    'group_page.messages.archive_group_success'
      redirect:   '/dashboard'


    canAdministerGroup: ->
      AbilityService.canAdministerGroup(@group)

    canEditGroup: ->
      AbilityService.canEditGroup(@group)

    canAddSubgroup: ->
      AbilityService.canCreateSubgroups(@group)

    canArchiveGroup: ->
      AbilityService.canArchiveGroup(@group)

    canLeaveGroup: ->
      AbilityService.canRemoveMembership(@group.membershipFor(Session.user()))

    canChangeVolume: ->
      AbilityService.canChangeGroupVolume(@group)
</script>

<template lang="pug">
v-menu.group-page-actions.lmo-no-print(v-if="canSeeGroupActions" offset-y)
  template(v-slot:activator="{on}")
    v-btn.group-page-actions__button(text v-on="on" v-t="'group_page.options.label'")
  v-list.group-actions-dropdown__menu-content

    v-list-item.group-page-actions__edit-group-link(v-if='canEditGroup', @click='editGroup()')
      v-list-item-title(v-t="'group_page.options.edit_group'")

    v-list-item.group-page-actions__become-coordinator(v-if='canBecomeCoordinator', @click='becomeCoordinator()')
      v-list-item-title(v-t="'group_page.options.become_coordinator'")

    v-list-item.group-page-actions__change-volume-link(v-if='canChangeVolume', @click='openChangeVolumeForm()')
      v-list-item-title(v-t="'group_page.options.email_settings'")

    v-list-item.group-page-actions__export-json(v-if='canExportData', @click='openGroupExportModal()')
      v-list-item-title(v-t="'group_page.options.export_data'")

    v-list-item.group-page-actions__leave-group(v-if='canLeaveGroup', @click='openLeaveGroupModal()')
      v-list-item-title(v-t="'group_page.options.leave_group'")

    v-list-item.group-page-actions__archive-group(v-if='canArchiveGroup', @click='openArchiveGroupModal()')
      v-list-item-title(v-t="'group_page.options.deactivate_group'")
</template>
