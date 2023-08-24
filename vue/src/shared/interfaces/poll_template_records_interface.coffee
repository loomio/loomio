import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import PollTemplateModel    from '@/shared/models/poll_template_model'

export default class PollTemplateRecordsInterface extends BaseRecordsInterface
  model: PollTemplateModel

  fetchAll: (groupId) ->
    @remote.fetch(params: {group_id: groupId})

  findOrFetchByKeyOrId: (keyOrId) ->
    record = @find(keyOrId)
    if record
      Promise.resolve(record)
    else
      @remote.fetch(params: {key_or_id: keyOrId}).then =>
        @find(keyOrId)

