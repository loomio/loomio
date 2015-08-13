angular.module('loomioApp').factory 'ThreadQueryService', (Records) ->
  new class ThreadQueryService

    filterQuery: (filter, options = {}) ->
      threadQueryFor createBaseView(filter, options['queryType'] or 'all')

    timeframeQuery: (options = {}) ->
      threadQueryFor createTimeframeView(options['name'], options['filter'] or 'show_all', 'timeframe', options['timeframe']['from'], options['timeframe']['to'])

    groupQuery: (group = {}, options = {}) ->
      threadQueryFor createGroupView(group, options['filter'] or 'show_unread', options['queryType'] or 'inbox')

    threadQueryFor = (view) ->
      threads: -> view.data()
      length: ->  @threads().length
      any: ->     @length() > 0

    createBaseView = (filters, queryType) ->
      _.memoize(->
        view = Records.discussions.collection.addDynamicView 'default'
        applyFilters(view, filters, queryType)
        view)()

    createGroupView = (group, filters, queryType) ->
      _.memoize(->
        view = Records.discussions.collection.addDynamicView group.name
        view.applyFind({groupId: { $in: group.organisationIds() }})
        applyFilters(view, filters, queryType)
        view)()

    createTimeframeView = (name, filters, queryType, from, to) ->
      today = moment().startOf 'day'
      _.memoize(->
        view = Records.discussions.collection.addDynamicView name
        view.applyFind(lastActivityAt: { $gt: parseTimeOption(from) })
        view.applyFind(lastActivityAt: { $lt: parseTimeOption(to) })
        applyFilters(view, filters, queryType)
        view)()

    parseTimeOption = (options) ->
      # we pass times in something human-readable like '1 month ago'
      # this translates that into today.subtract(1, 'month')
      parts = options.split ' '
      moment().startOf('day').subtract(parseInt(parts[0]), parts[1])

    applyFilters = (view, filters, queryType) ->
      switch queryType
        when 'important' then view.applyWhere (thread) -> thread.isImportant()
        when 'timeframe' then view.applyWhere (thread) -> !thread.isImportant()
        when 'inbox'     then view.applyWhere (thread) -> thread.isUnread()

      view.applyWhere (thread) -> thread.isMuted() == _.contains(filters, 'show_muted')

      _.each filters, (filter) ->
        switch filter
          when 'show_participating' then view.applyWhere (thread) -> thread.isParticipating()
          when 'show_starred'       then view.applyWhere (thread) -> thread.isStarred()
          when 'show_proposals'     then view.applyWhere (thread) -> thread.hasActiveProposal()
          when 'hide_proposals'     then view.applyWhere (thread) -> !thread.hasActiveProposal()

      view
