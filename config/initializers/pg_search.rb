PgSearch.multisearch_options = {
  using: {
    tsearch: {prefix: true, negation: true},
    # trigram: true,
  }
  #ignoring: :accents
}