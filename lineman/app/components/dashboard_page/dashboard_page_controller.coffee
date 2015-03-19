angular.module('loomioApp').controller 'DashboardPageController', (Records) ->
  @page = {}
  @perPage = 25

  @refresh = (options = {}) =>
    options['filter'] = @filter
    switch @sort
      when 'date'
        options['per'] = @perPage
        options['from'] = @page[@filter] = @page[@filter] || 0
        @page[@filter] = @page[@filter] + @perPage
        Records.discussions.fetchInboxByDate  options
      when 'group'
        Records.discussions.fetchInboxByGroup options

  @setOptions = (options = {}) =>
    @filter = options['filter'] if options['filter']
    @sort   = options['sort']   if options['sort']
    @refresh()

  @setOptions sort: 'group', filter: 'all'

  @dashboardDiscussions = ->
    window.Loomio.currentUser.inboxDiscussions()

  @dashboardGroups = ->
    window.Loomio.currentUser.groups()

  @footerReached = ->
    return false if @loadingDiscussions
    @loadingDiscussions = true
    @refresh().then ->
      @loadingDiscussions = false

  @unread = (discussion) ->
    discussion.isUnread() or @filter != 'unread'

  @lastInboxActivity = (discussion) ->
    -discussion.lastInboxActivity()

  @startOfDay = ->
    moment().startOf('day').clone()

  @today = (discussion) ->
    discussion.lastInboxActivity().isAfter @startOfDay()

  @yesterday = (discussion) ->
    discussion.lastInboxActivity().isBetween(@startOfDay().subtract(1, 'day'), @startOfDay())

  @thisWeek = (discussion) ->
    discussion.lastInboxActivity().isBetween(@startOfDay().subtract(1, 'week'), @startOfDay().subtract(1, 'day'))

  @thisMonth = (discussion) ->
    discussion.lastInboxActivity().isBetween(@startOfDay().subtract(1, 'month'), @startOfDay().subtract(1, 'week'))

  @older = (discussion) ->
    discussion.lastInboxActivity().isBefore(@startOfDay().subtract(1, 'month'))

  @anyToday = ->
    _.find @dashboardDiscussions(), (discussion) =>
      @today(discussion) and @unread(discussion)

  @anyYesterday = ->
    _.find @dashboardDiscussions(), (discussion) =>
      @yesterday(discussion) and @unread(discussion)

  @anyThisWeek = ->
    _.find @dashboardDiscussions(), (discussion) =>
      @thisWeek(discussion) and @unread(discussion)

  @anyThisMonth = ->
    _.find @dashboardDiscussions(), (discussion) =>
      @thisMonth(discussion) and @unread(discussion)

  @anyOlder = ->
    _.find @dashboardDiscussions(), (discussion) =>
      @older(discussion) and @unread(discussion)

  @anyThisGroup = (group) ->
    _.find @dashboardDiscussions(), (discussion) =>
      discussion.groupId == group.id and @unread(discussion)
  return
