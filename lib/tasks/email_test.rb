# RAILS_ENV=test TEST_EMAIL=mailcatcher rails runner lib/tasks/email_test.rb
# RAILS_ENV=test TEST_EMAIL=sendgrid rails runner lib/tasks/email_test.rb

#NB if using sendgrid, you need to have SENDGRID_USERNAME and SENDGRID_PASSWORD defined
#NB change the let(:addresses) below to define external targets

require 'spec_helper'
require 'faker'

def create_user
  stub_model User,
      name:               Faker::Name.name,
      email:              Faker::Internet.email,
      uses_markdown:      true,
      unsubscribe_token:  (('a'..'z').to_a+('0'..'9').to_a).sample(20).join,
      invitation_token:   (('a'..'z').to_a+('0'..'9').to_a).sample(20).join,
      groups:             []
end

def create_group
  mock_model Group,
      name:               Faker::Lorem.sentence(2),
      full_name:          Faker::Lorem.sentence(2)+ " - "+Faker::Lorem.sentence(2),
      admins:             [admin],
      admin_email:        admin.email,
      discussions:        [],
      discussions_count:  0,
      motions:            [],
      motions_count:      0
end

def create_discussion(in_group)
  stub_model Discussion,
     group:              in_group,
     author:             author,
     title:              Faker::Lorem.sentence(2),
     comments:           []
end

def create_comment(in_discussion)
  stub_model Comment,
    author:              author,
    created_at:          Time.now - rand(1..4).hours,
    body:                "test body *markdown*",
    uses_markdown:       true,
    discussion:          in_discussion
end

def create_motion(in_discussion)
  stub_model Motion,
      name:               Faker::Name.title,
      description:        Faker::Lorem.paragraph(rand(4..12)),
      discussion:         in_discussion,
      group:              in_discussion.group,
      author:             author,
      close_date:         Time.now+rand(300).minutes,
      votes_for_graph:    [["Yes (1)", 1, "Yes", [["himful@gmail.com"]]], ["Abstain (0)", 0, "Abstain", [[]]], ["No (0)", 0, "No", [[]]], ["Block (1)", 1, "Block", [["bob@lick.com"]]]],
      percent_voted:      50,
      group_count:        22,
      no_vote_count:      11
end

def create_vote
  stub_model Vote,
      user:               user,
      user_name:          Faker::Name.name,
      position_to_s:      ['agreed', 'abstained', 'disagreed', 'blocked'].sample,
      statement:          Faker::Lorem.paragraph(rand(0..2))
end


describe "Test Email:" do
  let (:addresses) { ['loomio.test.account@outlook.com'] }
  # let (:addresses) { ['loomio.test.account@outlook.com', 'loomio.testaccount@yahoo.com', 'loomio.testaccount@loomio.org'] }

	let(:user) { create_user }
  let(:author) { create_user }
  let(:admin) { create_user }

  let(:group) { create_group }
  let(:discussion) { create_discussion(group) }
  let(:comment) { stub_model Comment,
    author:              author,
    created_at:          Time.now - rand(1..4).hours,
    body:               "have you seen www.stuff.co.nz ? Foreman <a href=\"www.maliciouscode.com\" style=\"font-color:red\">can</a> help manage multiple processes that your Rails app depends upon when running in development. @johnirving would like this. It also provides an export command to move them into production. it's objectively the *best* for:\r\n \r\n- news \r\n- __stuff__ \r\n- things\r\n \r\n---\r\n \r\n## the `code` test section: \r\n \r\n```\r\nquestion = 'does it work'\r\nputs \" \#{question} ?\"\r\n```\r\n\r\n### also\r\n\r\nhere's a mockup of this email (how meta):\r\n[![](http://i.imgur.com/oLzk6ay.png)](http://i.imgur.com/oLzk6ay.png)",
    uses_markdown:       true,
    discussion:          discussion
  }

  let(:motion) { create_motion(discussion) }

  let(:vote) { stub_model Vote,
    user:               user,
    motion:             motion,
    user_name:          Faker::Name.name,
    position_to_s:      ['agreed', 'abstained', 'disagreed', 'blocked'].sample,
    statement:          Faker::Lorem.paragraph(rand(1..3))
  }

  let(:membership) { stub_model Discussion,
    group:              group,
    user:               user,
    inviter:            author
  }

  let(:group_request) { stub_model GroupRequest,
    group:              group,
    token:              ('a'..'z').to_a.sample(25).join
  }

  # describe "Discussion Mailer:" do
  #   it "new_discussion_created" do
  #     puts ' '
  #     puts 'NEW_DISCUSSION_CREATED'
  #     discussion.stub id: rand(1..1000)

  #     addresses.each do |email|
  #       user.stub email: email
  #       DiscussionMailer.new_discussion_created(discussion, user).deliver
  #       puts " ~ SENT (#{email})"
  #     end
  #   end
  # end

  # describe "Group Mailer:" do
  #   it "new_membership_request " do
  #     puts ' '
  #     puts 'NEW_MEMBERSHIP_REQUEST'

  #     addresses.each do |email|
  #       admin.stub email: email
  #       GroupMailer.new_membership_request(membership).deliver
  #       puts " ~ SENT (#{email})"
  #     end
  #   end

  #   it "group_email" do
  #     puts ' '
  #     puts 'GROUP_EMAIL'

  #     @subject = Faker::Lorem.sentence(4)
  #     @message = Faker::Lorem.paragraph(4)

  #     addresses.each do |email|
  #       user.stub email: email
  #       GroupMailer.group_email(group, author, @subject, @message, user).deliver
  #       puts " ~ SENT (#{email})"
  #     end
  #   end

  #  ### SKIP: this mailer just iterates above mailer ###
  #   # it "deliver_group_email" do
  #   # end
  # end

  # describe "Motion Mailer:" do
  #   it "new_motion_created" do
  #     puts ' '
  #     puts 'NEW_MOTION_CREATED'

  #     addresses.each do |email|
  #       user.stub email: email
  #       MotionMailer.new_motion_created(motion, user).deliver
  #       puts " ~ SENT (#{email})"
  #     end
  #   end

  #   it "motion_closed" do
  #     puts ' '
  #     puts 'MOTION_CLOSED'

  #     addresses.each do |email|
  #       MotionMailer.motion_closed(motion, email).deliver
  #       puts " ~ SENT (#{email})"
  #     end
  #   end

  #   it "motion_blocked" do
  #     puts ' '
  #     puts 'MOTION_BLOCKED'

  #     addresses.each do |email|
  #       vote.motion.author.stub email: email
  #       MotionMailer.motion_blocked(vote).deliver
  #       puts " ~ SENT (#{email})"
  #     end
  #   end
  # end

  # describe "Start_group Mailer:" do
    it "invite_admin_to_start_group" do
      puts ' '
      puts 'INVITE_ADMIN_TO_START_GROUP'

      addresses.each do |email|
        group_request.stub admin_email: email
        StartGroupMailer.invite_admin_to_start_group(group_request).deliver
        puts " ~ SENT (#{email})"
      end
    end
  # end

  describe "User Mailer:" do
    # it "daily_activity" do
    #   puts ' '
    #   puts 'DAILY_ACTIVITY'

    #   @activity = {}
    #   #create some groups
    #   user_groups = []
    #   rand(3..6).times { user_groups << create_group }
    #   user.stub groups: user_groups

    #   user.groups.each do |group_i|
    #     h = {}

    #     #create some discussions
    #     discussions = []
    #     (2..rand(5)).each do |k|
    #       a_discussion = create_discussion(group)
    #       #create some comments in that discussion
    #       rand(0..3).times do |l|
    #         a_comment = create_comment(a_discussion)
    #         a_discussion.comments << a_comment
    #       end
    #       discussions << a_discussion
    #     end
    #     h[:discussions] = discussions

    #     #create some motions
    #     motions = []
    #     (0..rand(2)).each do |k|
    #       a_motion = create_motion(discussion)
    #       motions << a_motion
    #     end
    #     h[:motions] = motions

    #     @activity[group_i.full_name] = h
    #   end

    #   @since_time = Time.now - 10.hours

    #   addresses.each do |email|
    #     user.stub email: email
    #     Discussion.any_instance.stub number_of_comments_since: rand(13)
    #     UserMailer.daily_activity(user, @activity, @since_time).deliver
    #     puts " ~ SENT (#{email})"
    #   end
    # end

    it "mentioned" do
      puts ' '
      puts 'MENTIONED'

      mailer_methods = {
      :mentioned_with_markdown => lambda do |email|
        user.stub email: email
        UserMailer.mentioned(user, comment)
      end,

      :mentioned_without_markdown => lambda do |email|
        user.stub email: email
        comment.stub uses_markdown: false
        UserMailer.mentioned(user, comment)
      end
      }

      addresses.each do |email|
        mailer_methods.each do |key, mailer_method|
          mailer_method.call(email).deliver
          puts " ~ SENT: (#{email}) : #{key}"
        end
      end
    end

    it "group_membership_approved" do
      puts ' '
      puts 'GROUP_MEMBERSHIP_APROVED'

      addresses.each do |email|
        user.stub email: email
        UserMailer.group_membership_approved(user, group).deliver
        puts " ~ SENT (#{email})"
      end
    end

    it "motion_closing_soon" do
      puts ' '
      puts 'MOTION_CLOSING_SOON'

      unique_votes = []
      rand(2..11).times { unique_votes << create_vote }
      motion.stub unique_votes: unique_votes

      addresses.each do |email|
        user.stub email: email
        UserMailer.motion_closing_soon(user, motion).deliver
        puts " ~ SENT (#{email})"
      end
    end

    it "added_to_group" do
      puts ' '
      puts 'ADDED_TO_GROUP'

      addresses.each do |email|
        membership.user.stub email: email
        UserMailer.added_to_group(membership).deliver
        puts " ~ SENT (#{email})"
      end
    end

    it "invited_to_loomio" do
      puts ' '
      puts 'INVITED_TO_LOOMIO'

      addresses.each do |email|
        user.stub email: email
        UserMailer.invited_to_loomio(user, author, group).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end
end
