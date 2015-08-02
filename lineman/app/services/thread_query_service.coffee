angular.module('loomioApp').factory 'ThreadQueryService', (Records) ->
  new class ThreadQueryService

    filterQuery: (filter, options = {}) ->
      threadQueryFor createBaseView(),
                     filter,
                     options['queryType'] or 'all'

    timeframeQuery: (options = {}) ->
      threadQueryFor createTimeframeView(options['name'], options['timeframe']),
                     options['filter'] or 'show_all',
                     options['queryType'] or 'timeframe'

    groupQuery: (group = {}, options = {}) ->
      threadQueryFor createGroupView(group),
                     options['filter'] or 'show_unread',
                     options['queryType'] or 'inbox'

    threadQueryFor = (view, filters, queryType) ->
      view:       view
      filter:     createFilter([].concat(filters), queryType)
      threads: -> @filter @view.data()
      length: ->  @threads().length
      any: ->     @length() > 0

    createBaseView = ->
      _.memoize(->
        view = Records.discussions.collection.addDynamicView 'default'
        view)()

    createGroupView = (group) ->
      _.memoize(->
        view = Records.discussions.collection.addDynamicView group.name
        view.applyFind({groupId: { $in: group.organisationIds() }})
        view)()

    createTimeframeView = (name, options = {}) ->
      today = moment().startOf 'day'
      _.memoize(->
        view = Records.discussions.collection.addDynamicView name
        view.applyFind(lastActivityAt: { $gt: parseTimeOption(options['from']) })
        view.applyFind(lastActivityAt: { $lt: parseTimeOption(options['to']) })
        view)()

    parseTimeOption = (options) ->
      # we pass times in something human-readable like '1 month ago'
      # this translates that into today.subtract(1, 'month')
      parts = options.split ' '
      moment().startOf('day').subtract(parseInt(parts[0]), parts[1])

    createFilter = (filters, queryType) ->
      (viewData) ->
        _.filter viewData, (thread) ->

          return false if queryType != 'inbox' and !thread.visibleInDashboard

          switch queryType
            when 'important' then return false if !thread.isImportant()
            when 'timeframe' then return false if thread.isImportant()
            when 'inbox'     then return false if !thread.visibleInInbox or !thread.isUnread()

          return false if _.contains(filters, 'show_muted')         !=   thread.isMuted()
          return false if _.contains(filters, 'show_participating') and !thread.isParticipating()
          return false if _.contains(filters, 'show_starred')       and !thread.isStarred()
          return false if _.contains(filters, 'show_proposals')     and !thread.hasActiveProposal()
          return false if _.contains(filters, 'hide_proposals')     and thread.hasActiveProposal()

          true
