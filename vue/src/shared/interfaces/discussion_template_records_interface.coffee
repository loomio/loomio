import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DiscussionTemplateModel  from '@/shared/models/discussion_template_model'

export default class DiscussionTemplateRecordsInterface extends BaseRecordsInterface
  model: DiscussionTemplateModel

  findOrFetchByKey: (key, groupId) ->
    record = @find(key)
    if record
      Promise.resolve(record)
    else
      @remote.fetch(params: {group_id: groupId}).then =>
        @find(key)