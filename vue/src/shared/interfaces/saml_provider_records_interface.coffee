import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import SamlProviderModel           from '@/shared/models/saml_provider_model'
# import {uniq, concat, compact, map, includes} from 'lodash'
export default class GroupRecordsInterface extends BaseRecordsInterface
  model: SamlProviderModel

  authenticateForGroup: (id) ->
    fetch("/saml_providers/should_auth?group_id=#{id}")
    .then (response) -> response.json().then (shouldAuth) ->
      window.location = "/saml_providers/auth?group_id=#{id}" if shouldAuth

  authenticateForDiscussion: (id) ->
    fetch("/saml_providers/should_auth?discussion_id=#{id}")
    .then (response) -> response.json().then (shouldAuth) ->
      window.location = "/saml_providers/auth?discussion_id=#{id}" if shouldAuth
