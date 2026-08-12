namespace :loomio do
  desc "Rebuild the typo-correction vocabulary from search documents"
  task rebuild_search_words: :environment do
    SearchService.rebuild_words
  end
end
