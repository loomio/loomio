<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import ConfirmModalMixin from '@/mixins/confirm_modal'
import GroupModalMixin from '@/mixins/group_modal'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'

export default
  mixins: [
    ConfirmModalMixin,
    GroupModalMixin,
    ChangeVolumeModalMixin
  ]
  props:
    group: Object
  methods:
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
      redirect: 'dashboard'

    archiveGroupModalConfirmOpts: ->
      submit:     @group.archive
      text:
        title:    'archive_group_form.title'
        helptext: 'archive_group_form.question'
        flash:    'group_page.messages.archive_group_success'
      redirect:   'dashboard'

    canExportData: ->
      Session.user().isMemberOf(@group)

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
v-menu.group-page-actions.lmo-no-print(offset-y)
  v-btn.group-page-actions__button(flat slot='activator')
    span(v-t="'group_page.options.label'")
    v-icon mdi-chevron-down
  v-list.group-actions-dropdown__menu-content

    v-list-tile.group-page-actions__edit-group-link(v-if='true', @click='editGroup()')
      v-list-tile-title(v-t="'group_page.options.edit_group'")

    v-list-tile.group-page-actions__change-volume-link(v-if='canChangeVolume', @click='openChangeVolumeForm()')
      v-list-tile-title(v-t="'group_page.options.email_settings'")

    v-list-tile.group-page-actions__export-json(v-if='canExportData', @click='openGroupExportModal()')
      v-list-tile-title(v-t="'group_page.options.export_data'")

    v-list-tile.group-page-actions__leave-group(v-if='canLeaveGroup', @click='openLeaveGroupModal()')
      v-list-tile-title(v-t="'group_page.options.leave_group'")

    v-list-tile.group-page-actions__archive-group(v-if='canArchiveGroup', @click='openArchiveGroupModal()')
      v-list-tile-title(v-t="'group_page.options.deactivate_group'")
</template>
