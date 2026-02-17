pageHelper = require('../helpers/pageHelper')

module.exports = {
  'browse_page_displays_templates': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_template_browse')
    page.expectText('.append-sort-here', 'Advice process')
    page.expectText('.append-sort-here', 'Consent process')
    page.expectText('.append-sort-here', 'Blank template')
    test.end()
  }
}
