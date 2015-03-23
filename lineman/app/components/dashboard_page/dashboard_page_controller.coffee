angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, Records) ->
  $rootScope.$broadcast('currentComponent', 'dashboardPage')

  @loaded =
    date:
      unread: 0
      all: 0
    group:
      unread: 0
      all: 0
  @perPage =
    date: 25
    group: 5
  @expandedGroupSize = 10
  @expandedGroups = []

  @loadMore = (options = {}) =>
    callFetch(
      filter:  @filter
      per:     @perPage[@sort]
      from:    @loadedCount()
      groupId: options['groupId']).then =>
      return if options['groupId']
      @loaded[@sort][@filter] = @loadedCount() + @perPage[@sort]

  callFetch = (params) =>
    if @sort == 'date' or params['groupId']
      Records.discussions.fetchInboxByDate(params)
    else
      Records.discussions.fetchInboxByGroup(params)

  @loadedCount = (groupId) =>
    if @groupIsExpanded(groupId)
      @expandedGroupSize
    else
      @loaded[@sort][@filter]

  @groupIsExpanded = (groupId) =>
    _.find(@expandedGroups, (id) -> id == groupId)

  @setOptions = (options = {}) =>
    @filter = options['filter'] if options['filter']
    @sort   = options['sort']   if options['sort']
    @loadMore() if @loadedCount() == 0
  @setOptions sort: 'group', filter: 'all'

  @dashboardDiscussions = =>
    _.sortBy(window.Loomio.currentUser.inboxDiscussions(), (discussion) =>
      @lastInboxActivity(discussion))
      .slice(0, @loadedCount())

  @dashboardGroups = ->
    _.filter window.Loomio.currentUser.groups(), (group) -> group.isParent()

  @footerReached = =>
    return false if @loadingDiscussionsDate
    @loadingDiscussionsDate = true
    @loadMore().then =>
      @loadingDiscussionsDate = false

  @loadMoreFromGroup = (group) =>
    loadKey = "loadingDiscussions#{group.id}"
    return false if @[loadKey]
    @[loadKey] = true
    @loadMore(groupId: group.id).then =>
      @expandedGroups.push group.id
      @[loadKey] = false

  @unread = (discussion) =>
    discussion.isUnread() or @filter != 'unread'

  @lastInboxActivity = (discussion) ->
    -discussion.lastInboxActivity()

  timeframe = (options = {}) ->
    today = moment().startOf 'day'
    (discussion) ->
      discussion.lastInboxActivity()
                .isBetween(today.clone().subtract(options['fromCount'] or 1, options['from']),
                           today.clone().subtract(options['toCount'] or 1, options['to']))

  inTimeframe = (fn) =>
    =>
      @loadedCount() > 0 and _.find @dashboardDiscussions(), (discussion) =>
        fn(discussion) and @unread(discussion)

  @today     = timeframe(from: 'second', toCount: -10, to: 'year')
  @yesterday = timeframe(from: 'day', to: 'second')
  @thisWeek  = timeframe(from: 'week', to: 'day')
  @thisMonth = timeframe(from: 'month', to: 'week')
  @older     = timeframe(fromCount: 3, from: 'month', to: 'month')

  @anyToday     = inTimeframe(@today)
  @anyYesterday = inTimeframe(@yesterday)
  @anyThisWeek  = inTimeframe(@thisWeek)
  @anyThisMonth = inTimeframe(@thisMonth)
  @anyOlder     = inTimeframe(@older)

  @groupName = (group) -> group.name

  @anyThisGroup = (group) =>
    @loadedCount() > 0 and _.find group.discussions(), (discussion) =>
      @unread(discussion)

  return
