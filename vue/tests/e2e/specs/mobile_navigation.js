const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'keeps_thread_action_tabs_in_view_when_switching_forms': test => {
    const page = pageHelper(test);
    page.resizeWindow(390, 844);
    page.loadPath('discussions/test_sampled_comments');
    page.waitFor('.comment-form .ProseMirror');
    page.click('.topic-page__latest button');
    page.waitFor('.sequenceId-30');
    page.pause(500);
    test.execute(() => window.scrollTo({top: document.documentElement.scrollHeight, behavior: 'instant'}));
    page.pause(200);
    page.fillRichText('.comment-form .ProseMirror', '<p>Keep this comment draft</p>');
    test.execute(() => {
      const fetchOriginal = window.fetch;
      window.fetch = (input, options) => {
        if (String(input).includes('/api/v1/poll_templates')) {
          return new Promise(resolve => setTimeout(() => resolve(fetchOriginal(input, options)), 700));
        }
        return fetchOriginal(input, options);
      };
      window.actionScrollCalls = [];
      const scrollWindow = window.scrollTo;
      window.scrollTo = function(...args) {
        window.actionScrollCalls.push({target: 'window', args, stack: new Error().stack});
        return scrollWindow.apply(this, args);
      };
      const scrollElement = Element.prototype.scrollTo;
      Element.prototype.scrollTo = function(...args) {
        if (this === document.scrollingElement) {
          window.actionScrollCalls.push({target: 'document', args, stack: new Error().stack});
        }
        return scrollElement.apply(this, args);
      };
    });
    page.click('.activity-panel__add-poll');
    page.pause(1200);
    test.execute(() => {
      const tabs = document.querySelector('.activity-panel__actions').getBoundingClientRect();
      const bottom = document.querySelector('.mobile-navigation').getBoundingClientRect().top;
      return {top: tabs.top, bottom: tabs.bottom, viewportBottom: bottom};
    }, [], result => {
      test.assert.ok(result.value.top >= 48, 'Action tabs stay below the title bar');
      test.assert.ok(result.value.bottom < result.value.viewportBottom - 100, 'The selected form remains in view after switching to a vote');
    });
    page.click('.activity-panel__actions [value="add-comment"]');
    page.pause(600);
    page.expectElement('.add-comment-panel .ProseMirror');
    page.expectText('.add-comment-panel .ProseMirror', 'Keep this comment draft');
    test.execute(() => {
      const tabs = document.querySelector('.activity-panel__actions').getBoundingClientRect();
      const bottom = document.querySelector('.mobile-navigation').getBoundingClientRect().top;
      const forms = document.querySelector('.actions-panel__forms');
      const commentPanel = forms.querySelector('[role="tabpanel"]:not([style*="display: none"])');
      return {formVisible: tabs.bottom < bottom - 100,
        height: forms.getBoundingClientRect().height, activeHeight: commentPanel.getBoundingClientRect().height};
    }, [], result => {
      test.assert.ok(result.value.formVisible, 'The comment form remains in view when switching back');
      test.assert.ok(Math.abs(result.value.height - result.value.activeHeight) < 2, 'The comment area has no space reserved from the vote form');
    });
    test.execute(() => window.actionScrollCalls, [], result => {
      test.assert.equal(result.value.length, 2, `Each tab click scrolls once after switching forms: ${JSON.stringify(result.value)}`);
    });
  },

  'opens_cached_threads_while_refresh_is_pending': test => {
    const page = pageHelper(test);
    page.resizeWindow(390, 844);
    page.loadPath('setup_dashboard');
    page.expectElement('.mobile-navigation a[aria-label="Dashboard"]');
    page.expectText('.dashboard-page__collections', 'Recent discussion');
    page.expectElement('.dashboard-page__mobile-search');
    page.expectNoElement('.navbar__sidenav-toggle');
    page.expectNoElement('.navbar__search');
    page.expectNoText('.mobile-navigation', 'Dashboard');
    page.expectNoText('.v-app-bar', 'Dashboard');
    test.execute(() => {
      const button = document.querySelector('.mobile-navigation a[aria-label="Dashboard"]');
      const style = getComputedStyle(button);
      return {height: button.getBoundingClientRect().height, padding: parseFloat(style.paddingTop)};
    }, [], result => {
      test.assert.ok(result.value.height >= 48, 'Bottom navigation has padded touch targets');
      test.assert.ok(result.value.padding >= 8, 'Navigation icons have vertical padding');
    });
    test.execute(() => {
      document.body.style.minHeight = '1600px';
      window.scrollTo(0, 220);
    });
    page.expectText('.v-app-bar-title', 'Dashboard');
    test.execute(() => {
      window.scrollTo(0, 0);
      document.body.style.minHeight = '';
    });
    page.expectNoText('.v-app-bar', 'Dashboard');

    page.click('.mobile-navigation button[aria-label="Open sidebar"]');
    page.expectElement('.sidebar__groups');
    test.execute(() => document.querySelector('.v-navigation-drawer__scrim').click());
    page.expectNoElement('.v-navigation-drawer__scrim');

    test.execute(() => {
      const fetchOriginal = window.fetch;
      window.fetch = (input, options) => {
        if (String(input).includes('/api/v1/topic_items')) {
          return new Promise(() => {});
        }
        return fetchOriginal(input, options);
      };
      const link = Array.from(document.querySelectorAll('.topic-preview__link'))
        .find(element => element.textContent.includes('Recent discussion'));
      link.click();
    });

    page.expectText('.topic-page__cached-context', 'Recent discussion');
    page.expectElement('.navbar__loading-slot .v-progress-circular');
    page.expectElement('.mobile-navigation button[aria-label="Thread menu"]');
    test.execute(() => {
      const bar = document.querySelector('.mobile-navigation').getBoundingClientRect();
      const latest = document.querySelector('.topic-page__latest').getBoundingClientRect();
      return bar.top - latest.bottom;
    }, [], result => test.assert.ok(result.value >= 8, 'Latest sits above the bottom navigation'));
    test.execute(() => window.scrollY, [], result => test.assert.equal(result.value, 0));
    page.click('.mobile-navigation button[aria-label="Thread menu"]');
    page.expectElement('.topic-sidebar');
  }
};
