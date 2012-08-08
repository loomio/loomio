require 'spec_helper'

describe CommentVote do
  it { should have_many(:events).dependent(:destroy) }
end
