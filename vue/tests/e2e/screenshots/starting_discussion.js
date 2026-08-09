const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'new_discussion_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_new_discussion');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.expectText('.discussions-panel__new-thread-button', 'New discussion');
    screenshot.capture('discussions/starting_a_discussion/new-discussion-button', {
      spotlight: {
        selector: '.discussions-panel__new-thread-button',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'new_discussion_form': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_new_discussion');
    page.click('.discussions-panel__new-thread-button');
    page.waitFor('.discussion-templates--template');
    page.execute("Array.from(document.querySelectorAll('.discussion-templates--template')).find(el => el.textContent.includes('Blank')).click()");
    page.waitFor('.discussion-form');
    page.fillIn('.discussion-form__title-input input', 'Plan the returnable bottle trial');
    page.fillIn(
      '.discussion-form .lmo-textarea div[contenteditable=true]',
      'Several cafes want to trial returnable glass bottles.\n\nCompare collection options, cleaning requirements, and costs before we agree on a plan.'
    );
    page.click('.tags-field__input .v-field');
    page.waitFor('.v-overlay .v-list-item');
    page.execute("Array.from(document.querySelectorAll('.v-overlay .v-list-item')).find(el => el.textContent.includes('Sustainability')).click()");
    page.click('.tags-field__input .v-field');
    page.waitFor('.v-overlay .v-list-item');
    page.execute("Array.from(document.querySelectorAll('.v-overlay .v-list-item')).find(el => el.textContent.includes('Packaging')).click()");
    page.click('.discussion-form__title-input input');
    page.execute('document.activeElement.blur()');
    page.pause(200);
    page.expectValue('.discussion-form__title-input input', 'Plan the returnable bottle trial');
    screenshot.captureElement('discussions/starting_a_discussion/new-discussion-example', '.discussion-form', {
      height: 1200
    });
  }
};
