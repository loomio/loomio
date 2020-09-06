import Records from '@/shared/services/records'
import { isNumber, uniq, compact, orderBy, camelCase, forEach, isObject } from 'lodash'
import Vue from 'vue'
import RangeSet         from '@/shared/services/range_set'

export default class ThreadLoader
  constructor: (discussion) ->
    @discussion = discussion
    @reset()

  reset: ->
    @collection = Vue.observable([])
    @rules = []
    @collapsed = Vue.observable({})

  collapse: (id) ->
    Vue.set(@collapsed, id, true)

  expand: (id) ->
    Vue.set(@collapsed, id, false)

  jumpToEarliest: ->
    @reset()
    @addLoadOldestFirstRule()
    @fetch()

  jumpToLatest: ->
    @reset()
    @addLoadNewestFirstRule()
    @fetch()

  jumpToUnread: ->
    @reset()
    @addLoadUnreadRule()
    @fetch()

  jumpToSequenceId: (id) ->
    @reset()
    @addLoadSequenceIdRule(id)
    @fetch()

  addLoadCommentRule: (commentId) ->
    @rules.push
      name: "comment from url"
      local:
        discussionId: @discussion.id
        commentId: {$gte: commentId}
      remote:
        order: 'sequence_id'
        discussion_id: @discussion.id
        comment_id: commentId

  addLoadPositionRule: (position) ->
    @rules.push
      name: "position from url"
      local:
        discussionId: @discussion.id
        depth: 1
        position: {$gte: position}
      remote:
        discussion_id: @discussion.id
        from_sequence_id_of_position: position
        order: 'sequence_id'

  addLoadSequenceIdRule: (sequenceId) ->
    @rules.push
      name: "sequenceId from url"
      local:
        discussionId: @discussion.id
        sequenceId: {$gte: sequenceId}
      remote:
        from: sequenceId
        order: 'sequence_id'

  addLoadNewestFirstRule: () ->
    @rules.push
      name: 'newest first'
      local:
        discussionId: @discussion.id
        position: {$gte: @discussion.createdEvent.childCount - 10}
      remote:
        discussion_id: @discussion.id
        from_sequence_id_of_position: @discussion.createdEvent.childCount - 10
        order: 'sequence_id'

  addLoadOldestFirstRule: ->
    @rules.push
      name: 'context'
      local:
        id: @discussion.createdEvent().id

    @rules.push
      name: 'oldest first'
      local:
        discussionId: @discussion.id
        sequenceId: {$gte: 1}
      remote:
        discussion_id: @discussion.id
        from_sequence_id_of_position: 1
        order: 'sequence_id'

  addLoadUnreadRule: ->
    if @discussion.updatedAt > @discussion.lastReadAt
      @rules.push
        name: "context updated"
        local:
          id: @discussion.createdEvent().id

    # if @discussion.readItemsCount() > 0 && @discussion.unreadItemsCount() > 0
    @rules.push
      name: {path: "thread_loader.new_to_you", args: {since: @discussion.lastReadAt}}
      local:
        discussionId: @discussion.id
        sequenceId: {$gte: @discussion.firstUnreadSequenceId()}
      remote:
        discussion_id: @discussion.id
        from: @discussion.firstUnreadSequenceId()
        order: 'sequence_id'
        per: 5


  addRule: (rule) ->
    @rules.push(rule)
    params = Object.assign {}, rule.remote, {exclude_types: 'group discussion'}
    Records.events.fetch(params: params).then (data) => @updateCollection()

  fetch:  ->
    @rules.forEach (rule) =>
      params = Object.assign {}, rule.remote, {exclude_types: 'group discussion'}
      Records.events.fetch(params: params).then (data) => @updateCollection()

  updateCollection: ->
    @records = []
    @readIds = []
    @rules.forEach (rule) =>
      args = Object.assign({}, rule.local)
      chain = Records.events.collection.chain()
      console.log(rule)
      forEach args, (value, key) ->
        if isObject(value)
          # eg: value = {$lte: asdads,  $gte: asdasd}
          forEach value, (subvalue, subkey) ->
            chain = chain.find({"#{key}": {"#{subkey}": subvalue}})
            console.log({"#{key}": {"#{subkey}": subvalue}}, chain.data())
        else
          # eg: value = 1
          chain = chain.find({"#{key}": value})

      @records = @records.concat(chain.data())

    @records = uniq orderBy @records, 'positionKey'
    # console.log @records
    # console.log("includes 00001-00001", @records.find((r) -> r.positionKey == "00001-00001"))
    # console.log(Records.events.collection.chain().find(positionKey: "00001-00001").data())

    # find records with no parentId or, where no event with that parentId in records
    eventIds = @records.map (event) -> event.id
    orphans = @records.filter (event) ->
      event.parentId == null || !eventIds.includes(event.parentId)

    parents = orphans.map (o) -> o.parentOrSelf()
    parents = uniq orderBy parents, 'positionKey'

    eventsByParentId = {}
    @records.forEach (event) =>
      eventsByParentId[event.parentId] = (eventsByParentId[event.parentId] || []).concat([event])
      @readIds.push(event.sequenceId) if RangeSet.includesValue(@discussion.readRanges, event.sequenceId)

    nest = (records) ->
      r = records.map (event) ->
        {event: event, children: (eventsByParentId[event.id] && nest(eventsByParentId[event.id])) || []}
      orderBy r, 'positionKey'

    @collection = nest(parents)

    # console.log 'rules', rules.length, rules
    # console.log 'eventIds', eventIds.length, eventIds
    # console.log 'orphans', orphans.length, orphans
    # console.log 'collection', @collection.length, @collection

    @collection
