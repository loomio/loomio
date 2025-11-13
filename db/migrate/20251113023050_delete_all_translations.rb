class DeleteAllTranslations < ActiveRecord::Migration[7.2]
  def change
    # we have been translating plain text as html, which leaves special chars like ` as html encoded sequences.
    # so we delete all the old translations and start fresh.
    Translation.delete_all
  end
end
