pageHelper = require('../helpers/pageHelper')

module.exports = {
  'browse_page_displays_templates': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_template_browse')
    page.expectText('.discussion-templates-browse-page', 'Advice process')
    page.expectText('.discussion-templates-browse-page', 'Consent process')
    test.end()
  }
}
