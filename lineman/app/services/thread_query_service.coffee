angular.module('loomioApp').factory 'ThreadQueryService', (Records, AbilityService, CurrentUser) ->
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
      view = Records.discussions.collection.addDynamicView 'default'
      applyFilters(view, filters, queryType)
      view

    createGroupView = (group, filters, queryType) ->
      view = Records.discussions.collection.addDynamicView group.name
      view.applyFind({groupId: { $in: group.organisationIds() }})
      applyFilters(view, filters, queryType)
      view

    createTimeframeView = (name, filters, queryType, from, to) ->
      today = moment().startOf 'day'
      view = Records.discussions.collection.addDynamicView name
      view.applyFind(lastActivityAt: { $gt: parseTimeOption(from) })
      view.applyFind(lastActivityAt: { $lt: parseTimeOption(to) })
      applyFilters(view, filters, queryType)
      view

    parseTimeOption = (options) ->
      # we pass times in something human-readable like '1 month ago'
      # this translates that into today.subtract(1, 'month')
      parts = options.split ' '
      moment().startOf('day').subtract(parseInt(parts[0]), parts[1])

    applyFilters = (view, filters, queryType) ->
      filters = [].concat filters

      view.applyFind(discussionReaderId: { $gt: 0 }) if AbilityService.isLoggedIn()

      switch queryType
        when 'important' then view.applyWhere (thread) -> thread.isImportant()
        when 'timeframe' then view.applyWhere (thread) -> !thread.isImportant()
        when 'inbox'
          view.applyFind(lastActivityAt: { $gt: moment().startOf('day').subtract(6, 'week').toDate() })
          view.applyWhere (thread) -> thread.isUnread()
          filters.push('show_not_muted')

      _.each filters, (filter) ->
        switch filter
          when 'show_muted'
            view.applyWhere (thread) -> thread.volume() == 'mute'
          when 'show_not_muted'
            view.applyWhere (thread) -> thread.volume() != 'mute'
          when 'only_threads_in_my_groups' then view.applyFind(groupId: {$in: CurrentUser.groupIds()})
          when 'show_participating'        then view.applyFind(participating: true)
          when 'show_starred'              then view.applyFind(starred: true)
          when 'show_proposals'            then view.applyWhere (thread) -> thread.hasActiveProposal()
          when 'hide_proposals'            then view.applyWhere (thread) -> !thread.hasActiveProposal()

      view
