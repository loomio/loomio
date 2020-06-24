import Records from '@/shared/services/records'

ids = {comment_ids: [] .... }

export default new class CommentService

  enqueFetch: (model) ->
    ids['comment_ids].push(model.id) if model.isA?('comment')
    ids['comment_ids].push(model.id) if model.isA?('comment')
    ids['comment_ids].push(model.id) if model.isA?('comment')
    ids['comment_ids].push(model.id) if model.isA?('comment')

  @fetchEnqueued()

  fetchEnqueued: debouce ->
    if ids['comment_ids'].any? or
      fetch(reactions, ids)
    @ids = {comment_ids: [], discussion_ids: []}
  , 5000
