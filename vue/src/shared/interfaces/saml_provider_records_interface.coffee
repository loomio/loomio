import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import SamlProviderModel           from '@/shared/models/saml_provider_model'
import Flash  from '@/shared/services/flash'
import EventBus  from '@/shared/services/event_bus'

export default class GroupRecordsInterface extends BaseRecordsInterface
  model: SamlProviderModel

  authenticateForGroup: (id) ->
    return unless AppConfig.features.app.group_sso
    fetch("/saml_providers/should_auth?group_id=#{id}")
    .then (response) -> response.json().then (shouldAuth) ->
      if shouldAuth
        EventBus.$emit 'closeModal'
        Flash.success 'configure_sso.redirecting'
        window.location = "/saml_providers/auth?group_id=#{id}"


  authenticateForDiscussion: (id) ->
    return unless AppConfig.features.app.group_sso
    fetch("/saml_providers/should_auth?discussion_id=#{id}")
    .then (response) -> response.json().then (shouldAuth) ->
      if shouldAuth
        EventBus.$emit 'closeModal'
        Flash.success 'configure_sso.redirecting'
        window.location = "/saml_providers/auth?discussion_id=#{id}" if shouldAuth
