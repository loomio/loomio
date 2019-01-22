import GroupPage from 'vue/components/group/page.vue'
import DashboardPage from 'vue/components/dashboard/page.vue'
import PollsPage from 'vue/components/polls/page.vue'
import InboxPage from 'vue/components/inbox/page.vue'
import ExplorePage from 'vue/components/explore/page.vue'
import ThreadPage from 'vue/components/thread/page.vue'
import ProfilePage from 'vue/components/profile/page.vue'

module.exports = [
  {path: '/dashboard', component: DashboardPage},
  {path: '/dashboard/:filter', component: DashboardPage},
  {path: '/polls', component: PollsPage},
  {path: '/polls/:filter', component: PollsPage},
  {path: '/inbox', component: InboxPage },
  # {path: '/groups', component: 'groupsPage' },
  {path: '/explore', component: ExplorePage},
  {path: '/profile', component: ProfilePage},
  # {path: '/contact', component: 'contactPage'},
  # {path: '/email_preferences', component: 'emailSettingsPage' },
  # {path: '/d/new', component: 'startDiscussionPage'},
  {path: '/d/:key', component: ThreadPage },
  {path: '/d/:key/:stub', component: ThreadPage },
  {path: '/d/:key/:stub/:sequence_id', component: ThreadPage },
  {path: '/d/:key/comment/:comment', component: ThreadPage},
  # {path: '/p/new', component: 'startPollPage'},
  # {path: '/p/new/:poll_type', component: 'startPollPage'},
  # {path: '/p/:key/', component: 'pollPage'},
  # {path: '/p/:key/:stub', component: 'pollPage'},
  # {path: '/g/:key/memberships', component: 'groupPage'},
  # {path: '/g/:key/membership_requests', component: 'membershipRequestsPage'},
  # {path: '/g/:key/documents', component: 'documentsPage'},
  # {path: '/g/:key/previous_polls', component: 'previousPollsPage'},
  # {path: '/g/new', component: 'startGroupPage'},
  {path: '/g/:key', component: GroupPage },
  {path: '/g/:key/:stub', component: GroupPage},
  # {path: '/u/:key', component: 'userPage' },
  # {path: '/u/:key/:stub', component: 'userPage' },
  # {path: '/apps/authorized', component: 'authorizedAppsPage'},
  # {path: '/apps/registered', component: 'registeredAppsPage'},
  # {path: '/apps/registered/:id', component: 'registeredAppPage'},
  # {path: '/apps/registered/:id/:stub', component: 'registeredAppPage'},
  # {path: '/slack/install', component: 'installSlackPage'},
  # {path: '/:handle', component: 'groupPage' },
]
