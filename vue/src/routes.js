import DashboardPage from './components/dashboard/page';
import GroupPage from './components/group/page.vue';
import TopicPage from './components/topic/page';

const InboxPage = () => import('./components/inbox/page');
const PollsToVoteOnPage = () => import('./components/dashboard/polls_to_vote_on_page');
const NotificationsPage = () => import('./components/notifications/page');
const ExplorePage = () => import('./components/explore/page');
const ProfilePage = () => import('./components/profile/page');
const PollVotesPage = () => import('./components/poll/votes_page');
const PollFormPage = () => import('./components/poll/form_page');
const PollTemplateFormPage = () => import('./components/poll_template/form_page');
const PollTemplateBrowsePage = () => import('./components/poll_template/browse_page');
const TasksPage = () => import('./components/tasks/page');
const BookmarksPage = () => import('./components/bookmarks/page');
const GroupDiscussionsPanel = () => import('./components/group/discussions_panel');
const GroupPollsPanel = () => import('./components/group/polls_panel');
const GroupEmailsPanel = () => import('./components/group/emails_panel');
const MembersPanel = () => import('./components/group/members_panel');
const MemberWeightsPage = () => import('./components/group/member_weights_page.vue');
const GroupTagsPanel = () => import('./components/group/tags_panel');
const GroupFilesPanel = () => import('./components/group/files_panel');
const MembershipRequestsPanel = () => import('./components/group/requests_panel');
const StartGroupPage = () => import('./components/start_group/page');
const ContactPage = () => import('./components/contact/page');
const EmailSettingsPage = () => import('./components/email_settings/page');
const DiscussionFormPage = () => import('./components/discussion/form_page');
const DiscussionTemplateFormPage = () => import('./components/discussion_template/form_page');
const DiscussionTemplateIndexPage = () => import('./components/discussion_template/index_page');
const DiscussionTemplateBrowsePage = () => import('./components/discussion_template/browse_page');
const UserPage = () => import('./components/user/page');
const TopicsPage = () => import('./components/topics/page');
const StartTrialPage = () => import('./components/start_trial/page.vue');
const ReportPage = () => import('./components/report/page.vue');

// import './config/catch_navigation_duplicated.js';

import { createRouter, createWebHistory } from 'vue-router'

const groupPageChildren = [
  {path: 'tags/:tag?', component: GroupTagsPanel, meta: {noScroll: true} },
  {path: 'emails', component: GroupEmailsPanel, meta: {noScroll: true}},
  {path: 'polls', component: GroupPollsPanel, meta: {noScroll: true}},
  {path: 'members/weights', component: MemberWeightsPage},
  {path: 'members', component: MembersPanel, meta: {noScroll: true}},
  {path: 'membership_requests', component: MembershipRequestsPanel, meta: {noScroll: true}},
  {path: 'files', component: GroupFilesPanel, meta: {noScroll: true}},
  {path: ':stub?', component: GroupDiscussionsPanel, meta: {noScroll: true}}
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),

  //   scrollBehavior(to, from, savedPosition) {
  //     if (savedPosition) {
  //       return savedPosition;
  //     } else if (to.meta.noScroll && from.meta.noScroll) {
  //       return window.scrollHeight;
  //     } else {
  //       return { x: 0, y: 0 };
  //     }
  //   },

  routes: [
    {path: '/demo', redirect: '/try'},
    {path: '/try', component: StartTrialPage},
    {path: '/users/sign_in', redirect: '/dashboard' },
    {path: '/users/sign_up', redirect: '/dashboard' },
    {path: '/tasks', component: TasksPage},
    {path: '/bookmarks', component: BookmarksPage},
    {path: '/report', component: ReportPage},
    {path: '/dashboard', component: DashboardPage},
    {path: '/dashboard/polls_to_vote_on', component: PollsToVoteOnPage},
    {path: '/notifications', component: NotificationsPage},
    {path: '/dashboard/:filter', component: DashboardPage},
    {path: '/dashboard/direct_discussions', component: TopicsPage},
    {path: '/inbox', component: InboxPage },
    {path: '/explore', component: ExplorePage},
    {path: '/profile', component: ProfilePage},
    {path: '/contact', component: ContactPage},
    {path: '/email_preferences', component: EmailSettingsPage },
    {path: '/p/:key/edit', component: PollFormPage },
    {path: '/p/:key/votes', component: PollVotesPage },
    {path: '/p/new', component: PollFormPage },
    {path: '/p/:key', component: TopicPage},
    {path: '/p/:key/comment/:comment_id', component: TopicPage},
    {path: '/p/:key/:stub', component: TopicPage},
    {path: '/p/:key/:stub/:sequence_id', component: TopicPage},
    {path: '/poll_templates/browse', component: PollTemplateBrowsePage},
    {path: '/poll_templates/new', component: PollTemplateFormPage},
    {path: '/poll_templates/:id/edit', component: PollTemplateFormPage},
    {path: '/u/:key/:stub?', component: UserPage },
    {path: '/d/new', component: DiscussionFormPage },
    {path: '/d/:key/edit', component: DiscussionFormPage },
    {path: '/discussion_templates/browse', component: DiscussionTemplateBrowsePage },
    {path: '/discussion_templates/new', component: DiscussionTemplateFormPage },
    {path: '/discussion_templates/:id', component: DiscussionTemplateFormPage },
    {path: '/discussion_templates', component: DiscussionTemplateIndexPage },
    {
      path: '/d/:key',
      component: TopicPage,
    },
    {
      path: '/d/:key/comment/:comment_id',
      component: TopicPage,
    },
    {
      path: '/d/:key/:stub',
      component: TopicPage,
    },
    {
      path: '/d/:key/:stub/:sequence_id',
      component: TopicPage,
    },
    {path: '/g/new', component: StartGroupPage},
    {path: '/g/:key', component: GroupPage, children: groupPageChildren, name: 'groupKey'},
    {path: '/:key', component: GroupPage, children: groupPageChildren},
    {path: '/', redirect: '/dashboard' }
  ]});

export default router;
