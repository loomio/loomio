class SearchResult
	include ActiveModel::Model
	include ActiveModel::Serialization

	attr_accessor :id,
	              :searchable_type,
	              :searchable_id,
	              :poll_title,
	              :discussion_title,
	              :discussion_key,
	              :highlight,
	              :poll_key,
	              :sequence_id,
	              :group_handle,
	              :group_key,
	              :group_name,
	              :author_name,
	              :author_id,
	              :authored_at,
	              :tags
end