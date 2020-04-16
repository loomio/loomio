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
          (group.adminMembershipsCount == 0 or group.parentOrSelf().adminsInclude(Session.user()))
      perform: ->
        Records.memberships.makeAdmin(membership).then ->
          Flash.success "memberships_page.messages.make_admin_success", name: Session.user().name

    group_stats:
      name: 'group_page.stats'
      icon: 'mdi-chart-bar'
      canPerform: ->
        AbilityService.canAdminister(group)
      perform: ->
        window.open("#{AppConfig.baseUrl}g/#{group.key}/stats?export=1", "_blank")

    export_data:
      name: 'group_page.options.export_data'
      icon: 'mdi-database-export'
      canPerform: ->
        membership && group.adminsInclude(Session.user())
      perform: ->
        openModal
          component: 'ExportDataModal'
          props:
            group: group

    webhooks:
      name: 'webhook.webhooks'
      icon: 'mdi-webhook'
      canPerform: ->
        group.adminsInclude(Session.user())
      perform: ->
        openModal
          component: 'WebhookList'
          props:
            group: group


    configure_sso:
      name: 'configure_sso.title'
      icon: 'mdi-key-variant'
      canPerform: ->
        AppConfig.features.app.group_sso &&
        AbilityService.canAdminister(group) && group.isParent()
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
