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

    canEditGroup: =>
      AbilityService.canEditGroup(@group)

    canAddSubgroup: ->
      AbilityService.canCreateSubgroups(@group)

    canArchiveGroup: =>
      AbilityService.canArchiveGroup(@group)

    canLeaveGroup: =>
      AbilityService.canRemoveMembership(@group.membershipFor(Session.user()))

    canChangeVolume: ->
      AbilityService.canChangeGroupVolume(@group)

  template:
    """
      <div class="group-page-actions lmo-no-print">
        {{ GroupActionsDropdown }}
        <!-- <md-menu md-position-mode="target-right target" class="lmo-dropdown-menu">
          <md-button ng-click="$mdMenu.open()" class="group-page-actions__button"> <span translate="group_page.options.label"></span> <i class="mdi mdi-chevron-down"></i></md-button>
          <md-menu-content class="group-actions-dropdown__menu-content">
              <md-menu-item ng-if="canEditGroup()" class="group-page-actions__edit-group-link">
                  <md-button ng-click="editGroup()"><span translate="group_page.options.edit_group"></span></md-button>
              </md-menu-item>
              <md-menu-item ng-if="canChangeVolume()" class="group-page-actions__change-volume-link">
                  <md-button ng-click="openChangeVolumeForm()"><span translate="group_page.options.email_settings"></span></md-button>
              </md-menu-item>
              <outlet name="after-group-actions-manage-memberships" model="group"></outlet>
              <outlet name="after-group-actions-manage-memberships-2" model="group"></outlet>
              <md-menu-item ng-if="canExportData()" class="group-page-actions__export-json">
                  <md-button ng-click="openGroupExportModal()"><span translate="group_page.options.export_data"></span></md-button>
              </md-menu-item>
              <md-menu-item ng-if="canLeaveGroup()" class="group-page-actions__leave-group">
                  <md-button ng-click="leaveGroup()"><span translate="group_page.options.leave_group"></span></md-button>
              </md-menu-item>
              <md-menu-item ng-if="canArchiveGroup()" class="group-page-actions__archive-group">
                  <md-button ng-click="archiveGroup()"><span translate="group_page.options.deactivate_group"></span></md-button>
              </md-menu-item>
          </md-menu-content>
        </md-menu> -->
      </div>
    """
