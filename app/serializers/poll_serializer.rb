class PollSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :discussion_id, :key, :poll_type, :title, :details, :mentioned_usernames, :stance_data, :closed_at, :closing_at, :stances_count, :created_at, :poll_option_names, :multiple_choice

  has_one :author, serializer: UserSerializer, root: :users
  has_one :outcome, serializer: OutcomeSerializer, root: :outcomes
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options
  has_one :my_stance, serializer: StanceSerializer, root: :stances

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def my_stance
    @my_stances_cache ||= scope[:my_stances_cache].get_for(object) if scope[:my_stances_cache]
  end
end
