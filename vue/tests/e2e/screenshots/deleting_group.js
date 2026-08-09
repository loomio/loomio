const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openDeleteGroup(page) {
  page.loadPath('setup_manual_oatmilk_group');
  page.expectText('.group-page__name', 'Oatmilk Cooperative');
  page.click('.group-page .action-dock .action-menu--btn');
  page.waitFor('.v-overlay .action-dock__button--destroy_group');
  page.expectText('.v-overlay .action-dock__button--destroy_group', 'Delete group');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'delete_group_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDeleteGroup(page);
    screenshot.capture('groups/deleting_your_group/group_delete_group', {
      spotlight: {
        selector: '.v-overlay .action-dock__button--destroy_group',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'delete_group_confirmation': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDeleteGroup(page);
    page.click('.v-overlay .action-dock__button--destroy_group');
    page.waitFor('.confirm-modal');
    page.expectText('.confirm-modal', "Type 'oatmilk-cooperative' to confirm");
    page.fillIn('.confirm-text-field input', 'oatmilk-cooperative');
    page.expectText('.confirm-modal__submit', 'Delete group');
    screenshot.captureElement('groups/deleting_your_group/group_delete_group_confirm', '.confirm-modal', {
      height: 1000
    });
  }
};
