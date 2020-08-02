import Records from '@/shared/services/records'
import { isNumber, uniq, compact, orderBy, camelCase } from 'lodash-es'
import Vue from 'vue'

export default class ThreadLoader
  constructor: (discussion) ->
    @discussion = discussion
    @reset()

  reset: ->
    @collection = Vue.observable([])
    @rules = []

  addRules: (rules) ->
    @rules.forEach @addRule

  addRule: (rule) ->
    console.log 'add rule', rule
    @rules.push(rule)

    return unless rule.remote
    params = Object.assign {}, rule.remote, {exclude_types: 'group discussion', per: 3}

    Records.events.fetch(params: params).then (data) =>
      @updateCollection()
      # Promise.resolve(@findEvent(rule.local))

  updateCollection: ->
    @records = []
    @rules.forEach (rule) =>
      args = Object.assign({}, rule.local)
      chain = Records.events.collection.chain()
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

    # console.log 'rules', rules.length, rules
    # console.log 'eventIds', eventIds.length, eventIds
    # console.log 'orphans', orphans.length, orphans
    # console.log 'collection', @collection.length, @collection

    @collection
