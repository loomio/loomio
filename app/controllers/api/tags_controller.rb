class API::TagsController < API::RestfulController
  def show
    load_and_authorize(:tag)
    respond_with_resource
  end

  def update_model
    load_and_authorize(:discussion, :update)
    group = @discussion.group.parent_or_self

    tag_names = Array(params[:tags]).uniq.sort

    existing_tag_names = Tag.where(group: group, name: tag_names).pluck(:name)
    (tag_names - existing_tag_names).each do |tag_name|
      Tag.create(name: tag_name, group: @discussion.group, color: "#bbb")
    end

    DiscussionTag.where(discussion: @discussion).destroy_all

    tag_names.each do |tag_name|
      tag = Tag.find_by(group: group, name: tag_name)
      DiscussionTag.create(discussion: @discussion, group: group, tag: tag)
    end

    @discussion.info[:tags] = tag_names
    @discussion.save(validate: false)

    group.info[:tags] = Tag.where(group: group).where('discussion_tags_count > 0').pluck(:name)
    group.save(validate: false)

    render json: Array(@discussion), scope: {}, each_serializer: DiscussionSerializer, root: 'discussions'
  end

  def index
    instantiate_collection { |collection| collection.where(group: load_and_authorize(:group)) }
    respond_with_collection
  end

  private

  def accessible_records
    current_user.tags
  end
end
