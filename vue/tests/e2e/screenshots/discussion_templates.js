const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'discussion_templates_list': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion_templates');
    page.waitFor('.discussion-templates-page');
    page.expectText('.discussion-templates-page', 'Bottle trial review');
    screenshot.captureElement(
      'discussions/templates/list',
      '.discussion-templates-page .v-card',
      {width: 1100, height: 1800}
    );
  },

  'discussion_template_form': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion_template_form');
    page.waitFor('.discussion-template-form');
    page.expectValue('.discussion-template-form-fields__title input', 'Returnable bottle trial review');
    page.expectElement('.discussion-template-form-fields__title-placeholder input');
    page.expectElement('.discussion-template-form__submit');
    screenshot.captureElement(
      'discussions/templates/form',
      '.discussion-template-form',
      {width: 1100, height: 3200}
    );
  },

  'discussion_from_template': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion_from_template');
    page.waitFor('.discussion-form');
    page.expectValue('#discussion-title', 'Returnable bottle trial review');
    screenshot.captureElement(
      'discussions/templates/use',
      '.discussion-form',
      {width: 1100, height: 2600}
    );
  }
};
