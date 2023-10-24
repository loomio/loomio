import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import AppConfig      from '@/shared/services/app_config'
import i18n from '@/i18n.coffee'
import { hardReload } from '@/shared/helpers/window'

export default new class GroupService
  actions: (group) ->
    membership = group.membershipFor(Session.user())
    
    # email_to_group:
    #   name: 'email_to_group.email_to_group_address'
    #   icon: 'mdi-send'
    #   menu: true
    #   canPerform: -> AbilityService.canStartThread(group)
    #   perform: ->
    #     openModal
    #       component: 'EmailToGroupSettings'
    #       props:
    #         group: group

    translate_group:
      name: 'common.action.translate'
      icon: 'mdi-translate'
      dock: 2
      canPerform: ->
        group.description && AbilityService.canTranslate(group)
      perform: ->
        Session.user() && group.translate(Session.user().locale)

    edit_group:
      name: 'group_page.options.edit_group'
      icon: 'mdi-cog'
      menu: true
      canPerform: ->
        AbilityService.canEditGroup(group)
      perform: ->
        openModal
          component: 'GroupForm'
          props:
            group: group.clone()

    change_volume:
      name: 'user_dropdown.email_settings'
      icon: 'mdi-email'
      menu: true
      canPerform: ->
        AbilityService.canChangeGroupVolume(group)
      perform: ->
        openModal
          component: 'ChangeVolumeForm'
          props:
            model: membership

    edit_tags: 
      icon: 'mdi-tag-outline'
      name: 'loomio_tags.card_title'
      menu: true
      canPerform: -> AbilityService.canAdminister(group)
      perform: ->
        EventBus.$emit 'openModal',
          component: 'TagsSelect',
          props:
            group: group

    become_coordinator:
      name: 'group_page.options.become_coordinator'
      icon: 'mdi-shield-star'
      menu: true
      canPerform: ->
        membership && membership.admin == false &&
          (group.adminMembershipsCount == 0 or group.parentOrSelf().adminsInclude(Session.user()))
      perform: ->
        Records.memberships.makeAdmin(membership).then ->
          Flash.success "memberships_page.messages.make_admin_success", name: Session.user().name

    chatbots:
      name: 'chatbot.chatbots'
      icon: 'mdi-robot'
      menu: true
      canPerform: ->
        group.adminsInclude(Session.user())
      perform: ->
        openModal
          component: 'ChatbotList'
          props:
            group: group

    api_docs:
      name: 'common.api_docs'
      icon: 'mdi-webhook'
      menu: true
      canPerform: -> group.adminsInclude(Session.user())
      perform: -> 
        hardReload "/help/api2/?group_id=#{group.id}"

    group_stats:
      name: 'group_page.stats'
      icon: 'mdi-chart-bar'
      menu: true
      canPerform: ->
        AbilityService.canAdminister(group)
      perform: ->
        window.open("#{AppConfig.baseUrl}g/#{group.key}/stats?export=1", "_blank")

    export_data:
      name: 'group_page.options.export_data'
      icon: 'mdi-database-export'
      menu: true
      canPerform: ->
        membership && group.adminsInclude(Session.user())
      perform: ->
        openModal
          component: 'ExportDataModal'
          props:
            group: group

    manage_subscription:
      name: 'subscription_status.manage_subscription'
      icon: 'mdi-credit-card-outline'
      menu: true
      perform: ->
        window.location = "/upgrade/#{group.id}"
      canPerform: ->
        AppConfig.features.app.subscriptions &&
        group.isParent() &&
        group.adminsInclude(Session.user())

    leave_group:
      name: 'group_page.options.leave_group'
      icon: 'mdi-exit-to-app'
      menu: true
      canPerform: ->
        AbilityService.canRemoveMembership(membership)
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: ->
                membership.destroy().then ->
                  Records.discussions.find(groupId: membership.groupId).forEach (d) -> d.update(discussionReaderUserId: null)

              text:
                title:    'leave_group_form.title'
                helptext: 'leave_group_form.question'
                confirm:  'leave_group_form.submit'
                flash:    'group_page.messages.leave_group_success'
              redirect: '/dashboard'

    destroy_group:
      name: 'delete_group_modal.title'
      icon: 'mdi-delete'
      menu: true
      canPerform: ->
        AbilityService.canArchiveGroup(group)
      perform: ->
        confirmText = group.handle || group.name.trim()
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: group.destroy
              text:
                title:    (group.isParent() && 'delete_group_modal.title') || 'delete_group_modal.subgroup_title'
                helptext: (group.isParent() && 'delete_group_modal.parent_body') || 'delete_group_modal.body' 
                raw_confirm_text_placeholder: i18n.t('delete_group_modal.confirm', name: confirmText)
                confirm_text: confirmText
                flash:    'delete_group_modal.success'
                submit:   'delete_group_modal.title'
              redirect:   '/dashboard'
