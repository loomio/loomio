angular.module('loomioApp').factory 'ThreadQueryService', (Records) ->
  new class ThreadQueryService

    unreadQuery: ->
      threadQueryFor createBaseView(), 'show_unread'

    groupQuery: (group = {}, options = {}) ->
      threadQueryFor createGroupView(group), 
                     options['filter'] or 'show_unread',
                     options['limit'] or 5

    timeframeQuery: (options = {}) ->
      threadQueryFor createTimeframeView(options['name'], options['timeframe']),
                     options['filter'] or 'show_all',
                     options['limit'] or 100

    threadQueryFor = (view, filter) ->
      view: view
      filter: createFilter(filter)
      threads: ->
        @filter @view.data()
      length: ->
        @threads().length
      any: ->
        @length() > 0

    createBaseView = ->
      _.memoize(->
        view = Records.discussions.collection.addDynamicView 'default'
        view.applySimpleSort('lastActivityAt', true)
        view)()

    createGroupView = (group) ->
      _.memoize(->
        view = Records.discussions.collection.addDynamicView group.name
        view.applyFind({groupId: { $in: group.organizationIds() }})
        view.applySimpleSort('lastActivityAt', true)
        view)()

    createTimeframeView = (name, options = {}) ->
      today = moment().startOf 'day'
      _.memoize(->
        view = Records.discussions.collection.addDynamicView name
        view.applyFind(lastActivityAt: { $gt: parseTimeOption(options['from']) })
        view.applyFind(lastActivityAt: { $lt: parseTimeOption(options['to']) })
        view.applySimpleSort('lastActivityAt', true)
        view)()

    parseTimeOption = (options) ->
      # we pass times in something human-readable like '1 month ago'
      # this translates that into today.subtract(1, 'month')
      parts = options.split ' '
      moment().startOf('day').subtract(parseInt(parts[0]), parts[1])

    createFilter = (filter = 'show_all') ->
      (viewData) ->
        _.filter viewData, (thread) ->
          return false if thread.isMuted() and filter != 'show_muted'
          return false if thread.readerNotLoaded()
          switch filter
            when 'show_all'           then true
            when 'show_muted'         then thread.isMuted()
            when 'show_unread'        then thread.isUnread()
            when 'show_participating' then thread.isParticipating()
            when 'show_proposals'     then thread.hasActiveProposal()
