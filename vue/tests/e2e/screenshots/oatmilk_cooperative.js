const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'group_overview': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    screenshot.captureElement('groups/group_page', '.group-page');
  },

  'group_settings_menu': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-menu--btn');
    page.waitFor('.v-overlay .v-list');
    screenshot.captureElement('groups/settings/group_settings', '.v-main', {
      spotlight: {
        selector: '.v-overlay .action-dock__button--edit_group',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'group_settings_profile': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--edit_group');
    page.click('.v-overlay .action-dock__button--edit_group');
    page.waitFor('.group-form');
    page.expectValue('.group-form__name input', 'Oatmilk Cooperative');
    page.expectValue('.group-form__handle input', 'oatmilk-cooperative');
    screenshot.captureElement('groups/settings/group_profile', '.group-form', {height: 1000});
  },

  'group_settings_privacy': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--edit_group');
    page.click('.v-overlay .action-dock__button--edit_group');
    page.waitFor('.group-form');
    page.click('.group-form__privacy-tab');
    page.waitFor('.group-form__privacy');
    page.execute("document.querySelector('.group-form__privacy-secret input').click()");
    test.expect.element('.group-form__privacy-secret input').to.be.selected;
    screenshot.captureElement('groups/settings/group_privacy_settings', '.group-form', {height: 800});
  },

  'group_join_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_join_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.expectText('.join-group-button', 'Join group');
    screenshot.capture('groups/settings/group_join_group', {
      spotlight: {
        selector: '.join-group-button',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'group_invite_actions': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page-members-tab');
    page.waitFor('.members-panel');
    page.expectText('.membership-card__invite', 'Invite');
    page.expectText('.members-panel__shareable-link-btn', 'Shareable Link');
    screenshot.capture('groups/settings/group_join_group_invite', {
      spotlight: {
        selectors: ['.membership-card__invite', '.members-panel__shareable-link-btn'],
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'group_settings_permissions': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--edit_group');
    page.click('.v-overlay .action-dock__button--edit_group');
    page.waitFor('.group-form');
    page.click('.group-form__permissions-tab');
    page.waitFor('.group-form__permissions');
    screenshot.captureElement('groups/settings/group_group_settings_permissions', '.group-form', {height: 1400});
  },

  'group_start_new': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.ensureSidebar();
    page.expectElement('.sidebar-start-group');
    screenshot.capture('groups/starting_a_group/new_group', {
      spotlight: {
        selector: '.sidebar-start-group',
        padding: 6,
        radius: 6
      }
    });
  },

  'group_start_form': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.ensureSidebar();
    page.click('.sidebar-start-group');
    page.waitFor('.group-form');
    page.fillIn('.group-form__name input', 'Oatmilk Producers Network');
    page.expectValue('.group-form__handle input', 'oatmilk-producers-network');
    page.click('.group-form__category-select .v-field');
    page.waitFor('.v-overlay .v-select__content .v-list-item');
    page.execute(`
      Array.from(document.querySelectorAll('.v-overlay .v-select__content .v-list-item'))
        .find((item) => item.textContent.includes('Self-managing organization'))
        .click()
    `);
    page.fillIn(
      '.group-form__group-description .ProseMirror',
      'We coordinate shared purchasing, distribution, and training for regional oat milk producers.'
    );
    page.expectValue('.group-form__name input', 'Oatmilk Producers Network');
    screenshot.captureElement('groups/starting_a_group/new_group_start', '.group-form', {height: 1200});
  },

  'proposal_discussion': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_discussion');
    page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
    page.execute("document.querySelector('.strand-item__load-more button')?.click()");
    page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
    screenshot.captureElement('discussions/discussion-example', '.strand-card', {height: 1100});
  }
};
