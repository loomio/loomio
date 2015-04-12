angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, Records, CurrentUser, LoadingService) ->
  $rootScope.$broadcast('currentComponent', 'dashboardPage')
  $rootScope.$broadcast('setTitle', 'Dashboard')

  @loaded = {}
  @perPage =
    sort_by_date: 25
    sort_by_group: 10

  @sort   = -> CurrentUser.dashboardSort
  @filter = -> CurrentUser.dashboardFilter

  @loadedCount = =>
    @loaded[@sort()] = @loaded[@sort()] or {}
    @loaded[@sort()][@filter()] = @loaded[@sort()][@filter()] or 0

  @updateLoadedCount = =>
    current = @loadedCount()
    @loaded[@sort()][@filter()] = current + @perPage[@sort()]

  @loadParams = ->
    filter: @filter()
    per:    @perPage[@sort()]
    from:   @loadedCount()

  @loadMore = (options = {}) =>
    @updateLoadedCount()
    switch @sort()
      when 'sort_by_date'  then Records.discussions.fetchInboxByDate(@loadParams())
      when 'sort_by_group' then Records.discussions.fetchInboxByGroup(@loadParams())
  LoadingService.applyLoadingFunction @, 'loadMore'

  @changePreferences = (options = {}) =>
    CurrentUser.updateFromJSON(options)
    CurrentUser.save()
    @loadMore() if @loadedCount() == 0

  @dashboardOptions = (group = {}) =>
    unmuted:   true
    unread:    @filter() == 'show_unread'
    proposals: @filter() == 'show_proposals'
    groupId:   group.id

  @dashboardDiscussionReaders = (group) =>
    _.pluck Records.discussionReaders.forDashboard(@dashboardOptions(group)).data(), 'id'

  @dashboardDiscussions = (group) =>
    Records.discussions.findByDiscussionIds(@dashboardDiscussionReaders(group))
                       .simplesort('lastActivityAt', true)
                       .data()

  @dashboardGroups = ->
    _.filter CurrentUser.groups(), (group) -> group.isParent()

  timeframe = (options = {}) ->
    today = moment().startOf 'day'
    (discussion) ->
      discussion.lastInboxActivity()
                .isBetween(today.clone().subtract(options['fromCount'] or 1, options['from']),
                           today.clone().subtract(options['toCount'] or 1, options['to']))

  @today     = timeframe(from: 'second', toCount: -10, to: 'year')
  @yesterday = timeframe(from: 'day', to: 'second')
  @thisWeek  = timeframe(from: 'week', to: 'day')
  @thisMonth = timeframe(from: 'month', to: 'week')
  @older     = timeframe(fromCount: 3, from: 'month', to: 'month')

  @groupName = (group) -> group.name
  @inGroup = (group) =>
    (discussion) =>
      discussion.groupId == group.id

  Records.votes.fetchMyRecentVotes()
  @loadMore()

  return
