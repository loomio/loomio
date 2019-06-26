import { camelCase } from 'lodash'

export default
  methods:
    componentForKind: (kind) ->
      camelCase if ['stance_created', 'new_comment', 'outcome_created', 'poll_created'].includes(kind)
        kind
      else
        'thread_item'
