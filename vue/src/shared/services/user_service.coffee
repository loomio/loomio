import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import { hardReload } from '@/shared/helpers/window'

export default new class UserService
  actions: (user, vm) ->
    change_password:
      icon: 'mdi-lock-reset'
      name: 'profile_page.change_password_link'
      canPerform: -> true
      perform: =>
        EventBus.$emit 'openModal',
          component: 'ChangePasswordForm',
          props:
            user: user

    deactivate_user:
      icon: 'mdi-exit-run'
      name: 'deactivate_user_form.title'
      canPerform: -> !user.deactivatedAt
      perform: =>
        EventBus.$emit 'openModal',
          component: 'ConfirmModal',
          props:
            confirm:
              text:
                title: 'deactivation_modal.aria_label'
                raw_helptext: "<p>#{vm.$t('deactivation_modal.introduction')}:</p>
                  <ul>
                    <li>#{vm.$t('deactivation_modal.no_longer_group_member')}</li>
                    <li>#{vm.$t('deactivation_modal.name_removed')}</li>
                    <li>#{vm.$t('deactivation_modal.no_emails')}</li>
                    <li>#{vm.$t('deactivation_modal.you_can_reactivate')}</li>
                  </ul>"
                submit: 'deactivation_modal.submit'
              submit: -> Records.users.deactivate(Session.user())
              successCallback: hardReload

    reactivate_user:
      icon: 'mdi-account-check'
      name: 'auth_form.reactivate'
      canPerform: -> user.deactivatedAt
      perform: =>
        EventBus.$emit 'openModal',
          component: 'ConfirmModal',
          props:
            confirm:
              text:
                title: 'auth_form.reactivate'
                submit: 'auth_form.reactivate'
              submit: -> Records.users.reactivate(Session.user())
              successCallback: -> Flash.success('auth_form.reactivate_link_sent')

    delete_user:
      icon: 'mdi-account-off'
      name: 'delete_user_modal.title'
      canPerform: -> true
      perform: =>
        EventBus.$emit 'openModal',
          component: 'ConfirmModal',
          props:
            confirm:
              text:
                title: 'delete_user_modal.title'
                raw_helptext: "<p>#{vm.$t('delete_user_modal.irreversable')}</p>
                  <ul>
                    <li>#{vm.$t('delete_user_modal.you_will_be_deleted')}</li>
                    <li>#{vm.$t('deactivation_modal.no_longer_group_member')}</li>
                    <li>#{vm.$t('deactivation_modal.name_removed')}</li>
                  </ul>"
                submit: 'delete_user_modal.submit'
              submit: -> Records.users.destroy()
              successCallback: hardReload
