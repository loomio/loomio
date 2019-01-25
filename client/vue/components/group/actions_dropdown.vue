<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

module.exports =
  props:
    group: Object
  methods:
    openGroupExportModal: ->
      ModalService.open 'ConfirmModal', confirm: =>
        submit: @group.export
        text:
          title:    'group_export_modal.title'
          helptext: 'group_export_modal.body'
          submit:   'group_export_modal.submit'
          flash:    'group_export_modal.flash'

    openChangeVolumeForm: ->
      ModalService.open 'ChangeVolumeForm', model: => @group.membershipFor(Session.user())

    editGroup: ->
      ModalService.open 'GroupModal', group: => @group

    addSubgroup: ->
      ModalService.open 'GroupModal', group: => Records.groups.build(parentId: @group.id)

    leaveGroup: ->
      ModalService.open 'ConfirmModal', confirm: =>
        submit:  Session.user().membershipFor(@group).destroy
        text:
          title:    'leave_group_form.title'
          helptext: 'leave_group_form.question'
          confirm:  'leave_group_form.submit'
          flash:    'group_page.messages.leave_group_success'
        redirect: 'dashboard'

    archiveGroup: ->
      ModalService.open 'ConfirmModal', confirm: =>
        submit:     @group.archive
        text:
          title:    'archive_group_form.title'
          helptext: 'archive_group_form.question'
          flash:    'group_page.messages.archive_group_success'
        redirect:   'dashboard'
  computed:
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

<template>
  <div class="group-page-actions lmo-no-print">
    <v-menu md-position-mode="target-right target" class="lmo-dropdown-menu">
      <v-btn flat slot="activator" class="group-page-actions__button">
        <span v-t="'group_page.options.label'"></span>
        <i class="mdi mdi-chevron-down"></i>
      </v-btn>
      <v-list class="group-actions-dropdown__menu-content">
        <v-list-tile v-if="canEditGroup" @click="editGroup()" class="group-page-actions__edit-group-link">
          <v-list-tile-title v-t="'group_page.options.edit_group'"></v-list-tile-title>
        </v-list-tile>
        <v-list-tile v-if="canChangeVolume" @click="openChangeVolumeForm()" class="group-page-actions__change-volume-link">
          <v-list-tile-title v-t="'group_page.options.email_settings'"></v-list-tile-title>
        </v-list-tile>

        <!-- <outlet name="after-group-actions-manage-memberships" model="group"></outlet>
        <outlet name="after-group-actions-manage-memberships-2" model="group"></outlet> -->

        <v-list-tile v-if="canExportData" @click="openGroupExportModal()" class="group-page-actions__export-json">
          <v-list-tile-title v-t="'group_page.options.export_data'"></v-list-tile-title>
        </v-list-tile>
        <v-list-tile v-if="canLeaveGroup" @click="leaveGroup()" class="group-page-actions__leave-group">
          <v-list-tile-title v-t="'group_page.options.leave_group'"></v-list-tile-title>
        </v-list-tile>
        <v-list-tile v-if="canArchiveGroup" @click="archiveGroup()" class="group-page-actions__archive-group">
          <v-list-tile-title v-t="'group_page.options.deactivate_group'"></v-list-tile-title>
        </v-list-tile>
      </v-list>
    </v-menu>
  </div>
</template>

<style lang="scss">
.group-page-actions {
  display: flex;
  align-items: center;
}

.group-actions-dropdown__menu-content .md-button {
  display: flex !important;
  align-items: center;
}

.group-actions-dropdown__menu-content {
  max-height: 400px;
}

.group-actions-dropdown__menu-content .mdi {
  font-size: 20px;
  margin-right: 8px;
}
</style>
