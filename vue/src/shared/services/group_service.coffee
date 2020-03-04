import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import AppConfig      from '@/shared/services/app_config'

export default new class GroupService
  actions: (group, vm) ->
    membership = group.membershipFor(Session.user())

    change_volume:
      name: 'group_page.options.email_settings'
      icon: 'mdi-email'
      canPerform: ->
        AbilityService.canChangeGroupVolume(group)
      perform: ->
        openModal
          component: 'ChangeVolumeForm'
          props:
            model: membership

    edit_group:
      name: 'group_page.options.edit_group'
      icon: 'mdi-settings'
      canPerform: ->
        AbilityService.canEditGroup(group)
      perform: ->
        openModal
          component: 'GroupForm'
          props:
            group: group

    become_coordinator:
      name: 'group_page.options.become_coordinator'
      icon: 'mdi-shield-star'
      canPerform: ->
        membership && membership.admin == false &&
          (group.adminMembershipsCount == 0 or
          Session.user().isAdminOf(group.parent()))
      perform: ->
        Records.memberships.makeAdmin(membership).then ->
          Flash.success "memberships_page.messages.make_admin_success", name: Session.user().name

    group_stats:
      name: 'group_page.stats'
      icon: 'mdi-chart-bar'
      canPerform: ->
        AbilityService.canAdministerGroup(group)
      perform: ->
        window.open("#{AppConfig.baseUrl}g/#{group.key}/stats?export=1", "_blank")

    export_data:
      name: 'group_page.options.export_data'
      icon: 'mdi-database-export'
      canPerform: ->
        membership && Session.user().isAdminOf(group)
      perform: ->
        openModal
          component: 'ExportDataModal'
          props:
            group: group

    install_slack:
      name: 'install_slack.modal_title'
      icon: 'mdi-slack'
      canPerform: ->
        AbilityService.canAdministerGroup(group) && !group.groupIdentityFor('slack')
      perform: ->
        openModal
          component: 'InstallSlackModal'
          props:
            group: group

    remove_slack:
      name: 'install_slack.remove_slack'
      icon: 'mdi-slack'
      canPerform: ->
        AbilityService.canAdministerGroup(group) && group.groupIdentityFor('slack')
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit:     group.groupIdentityFor('slack').destroy
              text:
                title:    'install_slack.card.confirm_remove_title'
                helptext: 'install_slack.card.confirm_remove_helptext'
                flash:    'install_slack.card.identity_removed'

    install_microsoft_teams:
      name: 'install_microsoft.card.install_microsoft'
      icon: 'mdi-microsoft'
      canPerform: ->
        # AppConfig.features.app.show_microsoft_card &&
        !group.groupIdentityFor('microsoft') &&
        AbilityService.canAdministerGroup(group)
      perform: ->
        openModal
          component: 'InstallMicrosoftTeamsModal'
          props:
            group: group

    remove_microsoft_teams:
      name: 'install_microsoft.card.remove_identity'
      icon: 'mdi-microsoft'
      canPerform: ->
        group.groupIdentityFor('microsoft') &&
        AbilityService.canAdministerGroup(group)
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit:     group.groupIdentityFor('microsoft').destroy
              text:
                title:    'install_microsoft.card.confirm_remove_title'
                helptext: 'install_microsoft.card.confirm_remove_helptext'
                flash:    'install_microsoft.card.identity_removed'

    configure_sso:
      name: 'configure_sso.title'
      icon: 'mdi-key-variant'
      canPerform: ->
        AbilityService.canAdministerGroup(group) && group.isParent()
      perform: ->
        openModal
          component: 'InstallSamlProviderModal'
          props:
            group: group

    leave_group:
      name: 'group_page.options.leave_group'
      icon: 'mdi-exit-to-app'
      canPerform: ->
        AbilityService.canRemoveMembership(membership)
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit:  membership.destroy
              text:
                title:    'leave_group_form.title'
                helptext: 'leave_group_form.question'
                confirm:  'leave_group_form.submit'
                flash:    'group_page.messages.leave_group_success'
              redirect: '/dashboard'

    archive_group:
      name: 'group_page.options.deactivate_group'
      icon: 'mdi-archive'
      canPerform: ->
        AbilityService.canArchiveGroup(group)
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit:     group.archive
              text:
                title:    'archive_group_form.title'
                helptext: 'archive_group_form.question'
                flash:    'group_page.messages.archive_group_success'
              redirect:   '/dashboard'
