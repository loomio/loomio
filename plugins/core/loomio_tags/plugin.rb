# module Plugins
#   module LoomioTags
#     class Plugin < Plugins::Base
#       setup! :loomio_tags do |plugin|
#         # plugin.enabled = true
#         #
#         # plugin.use_database_table :tags do |table|
#         #   table.belongs_to :group
#         #   table.string :name
#         #   table.string :color
#         #   table.integer :discussion_tags_count, default: 0
#         #   table.timestamps
#         # end
#         #
#         # plugin.use_database_table :discussion_tags do |table|
#         #   table.belongs_to :tag
#         #   table.belongs_to :discussion
#         #   table.timestamps
#         # end
#         # plugin.use_class_directory 'models'
#
#         # plugin.use_factory :tag do
#         #   association :group, factory: :formal_group
#         #   name "metatag"
#         #   color "#656565"
#         # end
#         #
#         # plugin.use_factory :discussion_tag do
#         #   discussion
#         #   tag
#         # end
#
#         # plugin.extend_class Discussion do
#         #   has_many :discussion_tags, dependent: :destroy
#         #   has_many :tags, through: :discussion_tags
#         # end
#
#         # plugin.extend_class FormalGroup do
#         #   has_many :tags, foreign_key: :group_id
#         # end
#
#         # plugin.extend_class User do
#         #   has_many :tags, through: :formal_groups
#         # end
#
#         # plugin.extend_class PermittedParams do
#         #   def discussion_tag
#         #     params.require(:discussion_tag).permit(:tag_id, :discussion_id)
#         #   end
#         #
#         #   def tag
#         #     params.require(:tag).permit(:name, :color, :group_id)
#         #   end
#         # end
#
#         # plugin.extend_class API::DiscussionsController do
#         #   module DiscussionsControllerTags
#         #     def tags
#         #       instantiate_collection do |collection|
#         #         collection.sorted_by_latest_activity.joins(:discussion_tags)
#         #                   .where('discussion_tags.tag_id': load_and_authorize(:tag).id)
#         #       end
#         #       respond_with_collection
#         #     end
#         #
#         #     private
#         #     def default_scope
#         #       super.merge(tag_cache: DiscussionTagCache.new(Array(resource || collection)).data)
#         #     end
#         #   end
#         #   prepend DiscussionsControllerTags
#         # end
#
#         # plugin.extend_class DiscussionSerializer do
#         #   has_many :discussion_tags
#         #
#         #   def discussion_tags
#         #     Array(Hash(scope).dig(:tag_cache, object.id))
#         #   end
#         # end
#
#         # plugin.use_class 'models/ability/discussion_tag'
#         # plugin.use_class 'models/ability/tag'
#         # plugin.extend_class Ability::Base do
#         #   prepend Ability::Tag
#         #   prepend Ability::DiscussionTag
#         # end
#
#         # plugin.extend_class LoggedOutUser do
#         #   def tags
#         #     Tag.none
#         #   end
#         # end
#
#         # plugin.use_route :get,    '/tags/:id',                 'tags#show'
#         # plugin.use_route :get,    '/tags',                     'tags#index'
#         # plugin.use_route :post,   '/tags',                     'tags#create'
#         # plugin.use_route :patch,  '/tags/:id',                 'tags#update'
#         # plugin.use_route :delete, '/tags/:id',                 'tags#destroy'
#         # plugin.use_route :get,    '/discussions/tags/:tag_id', 'discussions#tags'
#         # plugin.use_route :post,   '/discussion_tags',          'discussion_tags#create'
#         # plugin.use_route :delete, '/discussion_tags/:id',      'discussion_tags#destroy'
#
#         # plugin.use_class 'controllers/tags_controller'
#         # plugin.use_class 'controllers/discussion_tags_controller'
#         #
#         # plugin.use_class 'services/tag_service'
#         # plugin.use_class 'services/discussion_tag_service'
#         #
#         # plugin.use_class 'serializers/tag_serializer'
#         # plugin.use_class 'serializers/discussion_tag_serializer'
#
#
#         onf
#
#       end
#     end
#   end
# end
