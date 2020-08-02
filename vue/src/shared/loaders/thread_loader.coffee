import Records from '@/shared/services/records'
import { isNumber, uniq, compact, orderBy, camelCase } from 'lodash-es'
import Vue from 'vue'

export default class ThreadLoader
  constructor: (discussion) ->
    @discussion = discussion
    @reset()

  reset: ->
    @collection = Vue.observable([])
    @requests = []

  request: (args) ->
    console.log 'request', args
    @requests.push(args)
    @fetch(args).then => @updateCollection()

  fetch: (args) ->
    # if event = @findEvent(idType, id)
    #   Promise.resolve(event)
    # else
    params = switch args.column
      when 'sequenceId'
        from: args.id
        order: 'sequence_id'
      when 'commentId'
        comment_id: args.id
        order: 'sequence_id'
      when 'position'
        from_sequence_id_of_position: args.id
        order: 'sequence_id'

    params = Object.assign params,
      exclude_types: 'group discussion'
      discussion_id: @discussion.id
      per: 20

    console.log "fetch", params
    Records.events.fetch(params: params).then (data) =>
      console.log "back", data
      Promise.resolve(@findEvent(args.column, args.id))

  updateCollection: ->
    @records = []
    console.log 'updateCollection', @requests
    @requests.forEach (args) =>
      args = switch camelCase(args.column)
        when 'position'
          position: {$gte: args.id}
          depth: 1
        when 'sequenceId'
          sequenceId: {$gte: args.id}
        when 'commentId'
          kind: 'new_comment'
          eventableId: {$gte: args.id}
      args = Object.assign({}, args, {discussionId: @discussion.id, limit: (args.limit || 10)})
      chain = Records.events.collection.chain()
      delete(args.limit)
      Object.keys(args).forEach (key) ->
        chain = chain.find({"#{key}": args[key]})
      @records = @records.concat(chain.data())

    @records = uniq orderBy @records, 'positionKey'

    # find records with no parentId or, where no event with that parentId in records
    eventIds = @records.map (event) -> event.id
    orphans = @records.filter (event) ->
      event.parentId == null || !eventIds.includes(event.parentId)

    eventsByParentId = {}
    @records.forEach (event) ->
      eventsByParentId[event.parentId] = (eventsByParentId[event.parentId] || []).concat([event])

    nest = (records) ->
      records.map (event) ->
        {event: event, children: eventsByParentId[event.id] && nest(eventsByParentId[event.id])}

    @collection = nest(orphans)

    console.log 'collection', @collection.length, @collection

    @collection


  findEvent: (column, id) ->
    return false unless isNumber(id)
    records = Records
    if id == 0
      @discussion.createdEvent()
    else
      args = switch camelCase(column)
        when 'position'
          discussionId: @discussion.id
          position: id
          depth: 1
        when 'sequenceId'
          discussionId: @discussion.id
          sequenceId: id
        when 'commentId'
          kind: 'new_comment'
          eventableId: id
      # console.log "finding: ", args
      Records.events.find(args)[0]
