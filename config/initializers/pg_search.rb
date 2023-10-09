PgSearch.multisearch_options = {
  using: {
    tsearch: {
      prefix: true,
      negation: true,
      tsvector_column: 'ts_content',
      highlight: {
        StartSel: '<b>',
        StopSel: '</b>',
      }
    },
  }
}