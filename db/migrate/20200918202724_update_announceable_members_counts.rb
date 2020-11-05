class UpdateAnnounceableMembersCounts < ActiveRecord::Migration[5.2]
  def change
    # return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    #
    # max = Discussion.order('id desc').limit(1).pluck(:id).first
    # i = 0
    # step = 1000
    # while i < max do
    #   execute "UPDATE discussions d SET announceable_members_count = (
    #     SELECT count(id) FROM discussion_readers dr
    #     WHERE dr.discussion_id = d.id
    #     AND volume >= #{Membership.volumes[:normal]} ) WHERE d.id > #{i} AND d.id <= #{i+step}"
    #   i = i + step
    # end
    #
    # max = Group.order('id desc').limit(1).pluck(:id).first
    # i = 0
    # while i < max do
    #   execute "UPDATE groups g SET announceable_members_count = (
    #     SELECT count(id) FROM memberships m
    #     WHERE m.group_id = g.id
    #       AND volume >= #{Membership.volumes[:normal]}
    #       AND accepted_at IS NOT NULL
    #     )  WHERE g.id > #{i} AND g.id <= #{i+step}"
    #   i = i + step
    # end
  end
end
