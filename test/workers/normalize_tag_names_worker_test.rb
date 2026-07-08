require 'test_helper'

class NormalizeTagNamesWorkerTest < ActiveSupport::TestCase
  test "normalizes tag names" do
    called = false

    TagService.stub(:normalize_all_tag_names, -> { called = true }) do
      NormalizeTagNamesWorker.new.perform
    end

    assert called
  end
end
