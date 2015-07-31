angular.module('loomioApp').factory 'ThreadQueryService', (Records) ->
  new class ThreadQueryService

    filterQuery: (filter) ->
      threadQueryFor createBaseView(), filter

    groupQuery: (group = {}, options = {}) ->
      threadQueryFor createGroupView(group),
                     options['filter'] or 'show_unread',
                     false

    timeframeQuery: (options = {}) ->
      threadQueryFor createTimeframeView(options['name'], options['timeframe']),
                     options['filter'] or 'show_all',
                     true

    threadQueryFor = (view, filter, skipImportantThreads) ->
      view:       view
      filter:     createFilter(filter, skipImportantThreads)
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

    createFilter = (filter = 'show_recent', skipImportantThreads = false) ->
      (viewData) ->
        _.filter viewData, (thread) ->
          return false if skipImportantThreads and (thread.isStarred() or thread.hasActiveProposal())
          return false if thread.isMuted() and filter != 'show_muted'
          # return false unless thread.visibleOnDashboard
          switch filter
            when 'show_all'           then true
            when 'show_recent'        then !(thread.isStarred() or thread.hasActiveProposal())
            when 'show_muted'         then thread.isMuted()
            when 'show_unread'        then thread.isUnread()
            when 'show_participating' then thread.isParticipating()
            when 'show_starred'       then thread.isStarred() and !thread.hasActiveProposal()
            when 'show_proposals'     then thread.hasActiveProposal()
