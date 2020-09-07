import Records from '@/shared/services/records'
import { isNumber, uniq, compact, orderBy, camelCase, forEach, isObject } from 'lodash'
import Vue from 'vue'
import RangeSet         from '@/shared/services/range_set'
import Session from '@/shared/services/session'

padding = 20

export default class ThreadLoader
  constructor: (discussion) ->
    @discussion = discussion
    @reset()

  reset: ->
    @collection = Vue.observable([])
    @rules = []
    @unreadIds = []
    @collapsed = Vue.observable({})
    @rules.push
      name: "my stuff"
      local:
        find:
          discussionId: @discussion.id
          actorId: Session.user().id

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


  loadEverything: ->
    @titleKey = 'strand_nav.whole_thread'
    @addRule
      local:
        find:
          discussionId: @discussion.id
      remote:
        discussion_id: @discussion.id
        per: 1000

  loadChildren: (event) ->
    # @expand(event.id)
    if event.kind == "new_discussion"
      @addRule
        local:
          find:
            discussionId: @discussion.id
          simplesort: 'positionKey'
          limit: padding * 2
        remote:
          discussion_id: @discussion.id
          position_key_sw: event.positionKey
          order_by: 'position_key'
    else
      @addRule
        local:
          find:
            discussionId: @discussion.id
            positionKey: {'$regex': "^#{event.positionKey}"}
          simplesort: 'positionKey'
          limit: padding
        remote:
          discussion_id: @discussion.id
          position_key_sw: event.positionKey
          order_by: 'position_key'

  loadAfter: (event) ->
    @addRule
      local:
        find:
          discussionId: @discussion.id
          depth: {$gte: event.depth}
          positionKey: {$gt: event.positionKey}
        simplesort: 'positionKey'
        limit: padding
      remote:
        discussion_id: @discussion.id
        position_key_gt: event.positionKey
        # position_key_prefix: @positionKeyPrefix(event)
        depth_lte: event.depth + 2
        depth_gte: event.depth
        order_by: 'position_key'

  loadBefore: (event) ->
    @addRule
      local:
        find:
          discussionId: @discussion.id
          depth: event.depth
          positionKey: {$lt: event.positionKey}
        simplesort: 'positionKey'
        simplesortDesc: true
        limit: padding
      remote:
        discussion_id: @discussion.id
        depth: event.depth
        position_key_lt: event.positionKey
        order_by: 'position_key'
        order_desc: 1

    @addRule
      local:
        find:
          discussionId: @discussion.id
          depth: event.depth + 1
          positionKey: {$lt: event.positionKey}
        simplesort: 'positionKey'
        simplesortDesc: true
        limit: padding
      remote:
        discussion_id: @discussion.id
        depth: event.depth + 1
        position_key_lt: event.positionKey
        position_lt: 3
        order_by: 'position_key'
        order_desc: 1

  addLoadCommentRule: (commentId) ->
    @titleKey = 'strand_nav.from_comment'
    @rules.push
      name: "comment from url"
      local:
        find:
          discussionId: @discussion.id
          commentId: {$gte: commentId}
        limit: padding
      remote:
        order: 'sequence_id'
        discussion_id: @discussion.id
        comment_id: commentId

  addLoadPinnedRule: ->
    @titleKey = 'strand_nav.all_pinned'
    @rules.push
      name: "all pinned events"
      local:
        find:
          discussionId: @discussion.id
          pinned: true
        # position: {$gte: position}
      remote:
        discussion_id: @discussion.id
        pinned: true
        per: 200

  addLoadPositionRule: (position) ->
    @rules.push
      name: "position from url"
      local:
        find:
          discussionId: @discussion.id
          depth: 1
          position: {$gte: position}
      remote:
        discussion_id: @discussion.id
        from_sequence_id_of_position: position
        order: 'sequence_id'

  addLoadSequenceIdRule: (sequenceId) ->
    @titleKey = 'strand_nav.from_sequence_id'
    @rules.push
      name: "sequenceId from url"
      local:
        find:
          discussionId: @discussion.id
          sequenceId: {$gte: sequenceId}
        limit: padding
      remote:
        from: sequenceId
        order: 'sequence_id'

  addLoadNewestFirstRule: () ->
    @titleKey = 'strand_nav.newest_first'
    @rules.push
      local:
        find:
          id: @discussion.createdEvent().id
    @rules.push
      local:
        find:
          id: @discussion.createdEvent().id
        find:
          discussionId: @discussion.id
        simplesort: 'sequenceId'
        simplesortDesc: true
        limit: padding / 4
      remote:
        discussion_id: @discussion.id
        per: padding
        order_by: 'sequence_id'
        order_desc: true

  addLoadOldestFirstRule: ->
    @titleKey = 'strand_nav.oldest_first'
    @rules.push
      name: 'context'
      local:
        find:
          id: @discussion.createdEvent().id
      # remote:
      #   discussion_id: @discussion.id
      #   order_by: 'sequence_id'
      #   per: 1

    @rules.push
      name: 'oldest first'
      local:
        find:
          discussionId: @discussion.id
        simplesort: 'sequenceId'
        limit: padding
      remote:
        discussion_id: @discussion.id
        order_by: 'sequence_id'

  addLoadUnreadRule: ->
    @titleKey = 'strand_nav.unread'
    if @discussion.updatedAt > @discussion.lastReadAt
      @rules.push
        name: "context updated"
        local:
          find:
            id: @discussion.createdEvent().id

    # if @discussion.readItemsCount() > 0 && @discussion.unreadItemsCount() > 0
    @rules.push
      name: {path: "thread_loader.new_to_you", args: {since: @discussion.lastReadAt}}
      local:
        find:
          discussionId: @discussion.id
          sequenceId: {$or: @discussion.unreadRanges().map((r) -> {$between: r} )}
        limit: padding * 3
      remote:
        discussion_id: @discussion.id
        unread: true
        order_by: "sequence_id"
        # from: @discussion.firstUnreadSequenceId()
        # order: 'sequence_id'
        # per: 5


  addRule: (rule) ->
    @rules.push(rule)
    params = Object.assign {}, rule.remote, {exclude_types: 'group discussion'}
    Records.events.fetch(params: params)
    # Records.events.fetch(params: params).then (data) => @updateCollection()

  fetch:  ->
    @rules.forEach (rule) =>
      params = Object.assign {}, rule.remote, {exclude_types: 'group discussion'}
      Records.events.fetch(params: params)
      # Records.events.fetch(params: params).then (data) => @updateCollection()

  updateCollection: ->
    @records = []
    @rules.forEach (rule) =>
      args = Object.assign({}, rule.local.find)
      chain = Records.events.collection.chain()
      forEach args, (value, key) ->
        if isObject(value)
          # eg: value = {$lte: asdads,  $gte: asdasd}
          forEach value, (subvalue, subkey) ->
            chain = chain.find({"#{key}": {"#{subkey}": subvalue}})
            # console.log({"#{key}": {"#{subkey}": subvalue}}, chain.data())
        else
          # eg: value = 1
          chain = chain.find({"#{key}": value})

      if rule.local.simplesort
        chain = chain.simplesort(rule.local.simplesort, rule.local.simplesortDesc)

      if rule.local.limit
        chain = chain.limit(rule.local.limit)

      @records = @records.concat(chain.data())

    @records = uniq @records.concat(compact(@records.map (o) -> o.parent()))
    @records = orderBy @records, 'positionKey'
    eventIds = @records.map (event) -> event.id

    orphans = @records.filter (event) ->
      event.parentId == null || !eventIds.includes(event.parentId)
    # console.log @records
    # console.log("includes 00001-00001", @records.find((r) -> r.positionKey == "00001-00001"))
    # console.log(Records.events.collection.chain().find(positionKey: "00001-00001").data())

    # find records with no parentId or, where no event with that parentId in records


    eventsByParentId = {}
    @records.forEach (event) =>
      eventsByParentId[event.parentId] = (eventsByParentId[event.parentId] || []).concat([event])
      @unreadIds.push(event.sequenceId) if !RangeSet.includesValue(@discussion.readRanges, event.sequenceId)

    nest = (records) ->
      r = records.map (event) ->
        {event: event, children: (eventsByParentId[event.id] && nest(eventsByParentId[event.id])) || []}
      # orderBy r, 'positionKey'

    @collection = nest(orphans)

    # console.log 'rules', rules.length, rules
    # console.log 'eventIds', eventIds.length, eventIds
    # console.log 'orphans', orphans.length, orphans
    # console.log 'collection', @collection.length, @collection

    @collection
