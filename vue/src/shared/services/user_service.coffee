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
      perform: ->
        EventBus.$emit 'openModal',
          component: 'ChangePasswordForm',
          props:
            user: user

    merge_accounts:
      icon: 'mdi-account-multiple'
      name: 'profile_page.merge_accounts'
      canPerform: -> true
      perform: ->
        EventBus.$emit 'openModal',
          component: 'ConfirmModal'
          props:
            confirm:
              text:
                title: 'merge_accounts.modal.title'
                raw_helptext: vm.$t('merge_accounts.placeholder_modal_text')

    deactivate_user:
      icon: 'mdi-exit-run'
      name: 'profile_page.delete_user_link'
      canPerform: -> !user.deactivatedAt
      perform: ->
        EventBus.$emit 'openModal',
          component: 'ConfirmModal',
          props:
            confirm:
              text:
                title: 'profile_page.delete_account'
                raw_helptext: "
                  <p>#{vm.$t('deactivation_modal.introduction')}</p>
                  <ul>
                    <li>#{vm.$t('deactivation_modal.you_will_be_deleted')}</li>
                    <li>#{vm.$t('deactivation_modal.name_removed')}</li>
                    <li>#{vm.$t('deactivation_modal.no_longer_group_member')}</li>
                    <li>#{vm.$t('deactivation_modal.no_emails')}</li>
                  </ul>"
                submit: 'deactivation_modal.submit_delete'
              submit: -> Records.users.destroy()
              successCallback: hardReload
