const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

const editor = '.comment-form .lmo-textarea';
const proseMirror = `${editor} .ProseMirror`;
let scenarioKey = 100;

function openTaskEditor(page) {
  scenarioKey += 1;
  page.loadPath(`setup_manual_oatmilk_formatting?key=${scenarioKey}`);
  page.waitFor('.topic-page');
  page.waitFor(proseMirror);
  page.execute("const el = document.querySelector('.comment-form .ProseMirror'); el.focus(); el.innerHTML = '<p><br class=\"ProseMirror-trailingBreak\"></p>'; el.dispatchEvent(new InputEvent('input', {bubbles: true, inputType: 'deleteContentBackward'}))");
  page.click(`${editor} .html-editor__expand`);
  page.waitFor(`${editor} button[title="Task list"]`);
}

function selectEditorText(page) {
  page.execute("const el = document.querySelector('.comment-form .ProseMirror'); const range = document.createRange(); range.selectNodeContents(el); const selection = window.getSelection(); selection.removeAllRanges(); selection.addRange(range)");
}

function fillTask(page) {
  openTaskEditor(page);
  page.fillIn(proseMirror, 'Confirm bottle washer capacity with suppliers');
  selectEditorText(page);
  page.click(`${editor} button[title="Task list"]`);
  page.waitFor(`${editor} .task-item-text`);
  page.execute('window.getSelection().removeAllRanges(); document.activeElement.blur()');
}

function fillAssignedTask(page) {
  openTaskEditor(page);
  page.fillIn(proseMirror, 'Confirm bottle washer capacity with suppliers @jamie');
  page.waitForPresent('.suggestion-list [data-mention-handle="jamiechen"] .v-list-item-title');
  page.clickElement('.suggestion-list [data-mention-handle="jamiechen"] .v-list-item-title');
  selectEditorText(page);
  page.click(`${editor} button[title="Task list"]`);
  page.waitFor(`${editor} .task-item-text`);
  page.waitFor(`${editor} .task-item-text + .v-chip`);
  page.execute('window.getSelection().removeAllRanges(); document.activeElement.blur()');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'tasklist1': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    fillTask(page);
    screenshot.captureRegion('discussions/tasks/tasklist1', [editor], {
      spotlight: {
        selector: `${editor} button[title="Task list"]`,
        padding: 10,
        radius: 12
      },
      padding: 32,
      width: 1100,
      height: 1200
    });
  },

  'tasklist2': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    fillAssignedTask(page);
    screenshot.captureRegion('discussions/tasks/tasklist2', [editor], {
      padding: 32,
      width: 1100,
      height: 1200
    });
  },

  'task_list': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_tasks');
    page.waitFor('.dashboard-page');
    page.expectText('.dashboard-page', 'Confirm bottle washer capacity with suppliers');
    screenshot.capture('discussions/tasks/task_list', {
      spotlight: {
        selector: '.sidenav-left a[href="/tasks"]',
        padding: 10,
        radius: 12
      },
      width: 1280,
      height: 900
    });
  },

  'taskreminderform': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    fillAssignedTask(page);
    page.click(`${editor} .task-item-text + .v-chip`);
    page.waitFor('.v-dialog .v-card');
    screenshot.captureElement('discussions/tasks/taskreminderform', '.v-dialog .v-card', {
      width: 1100,
      height: 1200
    });
  },

  'taskdone': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_task_discussion');
    page.waitFor('.context-panel__description');
    page.expectText('.context-panel__description', 'Share cafe collection dates');
    screenshot.captureRegion('discussions/tasks/taskdone', ['.context-panel__description'], {
      padding: 32,
      width: 1100,
      height: 1000
    });
  }
};
