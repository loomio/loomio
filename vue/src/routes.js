import DashboardPage from './components/dashboard/page';
import GroupPage from './components/group/page.vue';
import TopicPage from './components/topic/page';

const InboxPage = wrapAsyncLoader(() => import('./components/inbox/page'));
const PollsToVoteOnPage = wrapAsyncLoader(() => import('./components/dashboard/polls_to_vote_on_page'));
const ExplorePage = wrapAsyncLoader(() => import('./components/explore/page'));
const ProfilePage = wrapAsyncLoader(() => import('./components/profile/page'));
const PollReceiptsPage = wrapAsyncLoader(() => import('./components/poll/receipts_page'));
const PollVotesPage = wrapAsyncLoader(() => import('./components/poll/votes_page'));
const PollFormPage = wrapAsyncLoader(() => import('./components/poll/form_page'));
const PollTemplateFormPage = wrapAsyncLoader(() => import('./components/poll_template/form_page'));
const PollTemplateBrowsePage = wrapAsyncLoader(() => import('./components/poll_template/browse_page'));
const TasksPage = wrapAsyncLoader(() => import('./components/tasks/page'));
const BookmarksPage = wrapAsyncLoader(() => import('./components/bookmarks/page'));
const GroupDiscussionsPanel = wrapAsyncLoader(() => import('./components/group/discussions_panel'));
const GroupPollsPanel = wrapAsyncLoader(() => import('./components/group/polls_panel'));
const GroupEmailsPanel = wrapAsyncLoader(() => import('./components/group/emails_panel'));
const MembersPanel = wrapAsyncLoader(() => import('./components/group/members_panel'));
const GroupTagsPanel = wrapAsyncLoader(() => import('./components/group/tags_panel'));
const GroupFilesPanel = wrapAsyncLoader(() => import('./components/group/files_panel'));
const MembershipRequestsPanel = wrapAsyncLoader(() => import('./components/group/requests_panel'));
const StartGroupPage = wrapAsyncLoader(() => import('./components/start_group/page'));
const ContactPage = wrapAsyncLoader(() => import('./components/contact/page'));
const EmailSettingsPage = wrapAsyncLoader(() => import('./components/email_settings/page'));
const DiscussionFormPage = wrapAsyncLoader(() => import('./components/discussion/form_page'));
const DiscussionTemplateFormPage = wrapAsyncLoader(() => import('./components/discussion_template/form_page'));
const DiscussionTemplateIndexPage = wrapAsyncLoader(() => import('./components/discussion_template/index_page'));
const DiscussionTemplateBrowsePage = wrapAsyncLoader(() => import('./components/discussion_template/browse_page'));
const UserPage = wrapAsyncLoader(() => import('./components/user/page'));
const TopicsPage = wrapAsyncLoader(() => import('./components/topics/page'));
const StartTrialPage = wrapAsyncLoader(() => import('./components/start_trial/page.vue'));
const ReportPage = wrapAsyncLoader(() => import('./components/report/page.vue'));

// import './config/catch_navigation_duplicated.js';

import { createRouter, createWebHistory } from 'vue-router'
import { wrapAsyncLoader, installRouterChunkErrorHandler } from '@/shared/services/chunk_error_handling'

const groupPageChildren = [
  {path: 'tags/:tag?', component: GroupTagsPanel, meta: {noScroll: true} },
  {path: 'emails', component: GroupEmailsPanel, meta: {noScroll: true}},
  {path: 'polls', component: GroupPollsPanel, meta: {noScroll: true}},
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
    {path: '/dashboard/:filter', component: DashboardPage},
    {path: '/dashboard/direct_discussions', component: TopicsPage},
    {path: '/inbox', component: InboxPage },
    {path: '/explore', component: ExplorePage},
    {path: '/profile', component: ProfilePage},
    {path: '/contact', component: ContactPage},
    {path: '/email_preferences', component: EmailSettingsPage },
    {path: '/p/:key/edit', component: PollFormPage },
    {path: '/p/:id/receipts', component: PollReceiptsPage, props: true },
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

installRouterChunkErrorHandler(router)
export default router;
