####To send to Mailcatcher####
#1. Start mailcatcher in terminal (if you need to install it, run `gem install mailcatcher`)
#2. Open mailcatcher in your browser at http://localhost:1080
#3. in terminal, run:
#      RAILS_ENV=test TEST_EMAIL=mailcatcher rails runner lib/tasks/email_test.rb

####To send using Sendgrid####
#1. Start mailcatcher in terminal (if you need to install it, run `gem install mailcatcher`)
#2. Open mailcatcher in your browser at http://localhost:1080
#3. Make sure you have a sengrid username and password to send emails through sendgrid
#4. In terminal, run:
#      RAILS_ENV=test TEST_EMAIL=sendgrid SENDGRID_USERNAME=***** SENDGRID_PASSWORD=****** rails runner lib/tasks/email_test.rb

#NB Edit the let(:addresses) below to define external targets  (~line 85)
#NB If you are running this command several times, consider adding SENDGRID_USERNAME and SENDGRID_PASSWORD to your .bash_profile or .zshrc file
#   To the bottom of the file add the lines like:
#       export SENDGRID_USERNAME=*******

require 'spec_helper'
require 'faker'

def create_user
  stub_model User,
      name:               Faker::Name.name,
      email:              Faker::Internet.email,
      language_preference: "es",
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
     description:        "# Kill the Loomio Helper Bot \n\nIs really keen for your group to  *get this done*. Apparently the space-cheese is delicious. But the implications for your carbon footprint are worrying.",
     uses_markdown:      true,
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
      description:        "Loomio Helper Bot is really keen for your group to invest in a trip to the moon. Apparently the space-cheese is delicious. But the implications for your carbon footprint are worrying.\n\nIs it a good idea? Loomio Helper Bot wants to know what you think!\n\nIf you're clear about your position, click one of the icons below (hover over the decision buttons for a description of what each one means).\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.",
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

  describe "Discussion Mailer:" do
    it "new_discussion_created" do
      puts ' '
      puts 'NEW_DISCUSSION_CREATED'
      discussion.stub id: rand(1..1000)

      addresses.each do |email|
        user.stub email: email
        DiscussionMailer.new_discussion_created(discussion, user).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end

  describe "Group Mailer:" do
    it "new_membership_request " do
      puts ' '
      puts 'NEW_MEMBERSHIP_REQUEST'

      addresses.each do |email|
        admin.stub email: email
        User.stub(:find_by_email).and_return(admin)
        GroupMailer.new_membership_request(membership).deliver
        puts " ~ SENT (#{email})"
      end
    end

    it "group_email" do
      puts ' '
      puts 'GROUP_EMAIL'

      @subject = Faker::Lorem.sentence(4)
      @message = Faker::Lorem.paragraph(4)

      addresses.each do |email|
        user.stub email: email
        GroupMailer.group_email(group, author, @subject, @message, user).deliver
        puts " ~ SENT (#{email})"
      end
    end

   ### SKIP: this mailer just iterates above mailer ###
    # it "deliver_group_email" do
    # end
  end

  describe "Motion Mailer:" do
    it "new_motion_created" do
      puts ' '
      puts 'NEW_MOTION_CREATED'

      addresses.each do |email|
        user.stub email: email
        MotionMailer.new_motion_created(motion, user).deliver
        puts " ~ SENT (#{email})"
      end
    end

    it "motion_closed" do
      puts ' '
      puts 'MOTION_CLOSED'

      addresses.each do |email|
        User.stub(:find_by_email).and_return(admin)
        MotionMailer.motion_closed(motion, email).deliver
        puts " ~ SENT (#{email})"
      end
    end

    it "motion_blocked" do
      puts ' '
      puts 'MOTION_BLOCKED'

      addresses.each do |email|
        vote.motion.author.stub email: email
        MotionMailer.motion_blocked(vote).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end

  # describe "Start_group Mailer:" do
  #   it "invite_admin_to_start_group" do
  #     puts ' '
  #     puts 'INVITE_ADMIN_TO_START_GROUP'

  #     addresses.each do |email|
  #       group_request.stub admin_email: email
  #       StartGroupMailer.invite_admin_to_start_group(group_request).deliver
  #       puts " ~ SENT (#{email})"
  #     end
  #   end
  # end
  #
  # DEPRECATED
  describe "verification"
  describe "defer"

  describe "User Mailer:" do
    it "daily_activity" do
      puts ' '
      puts 'DAILY_ACTIVITY'

      @activity = {}
      #create some groups
      user_groups = []
      rand(3..6).times { user_groups << create_group }
      user.stub groups: user_groups

      user.groups.each do |group_i|
        h = {}

        #create some discussions
        discussions = []
        (2..rand(5)).each do |k|
          a_discussion = create_discussion(group)
          #create some comments in that discussion
          rand(0..3).times do |l|
            a_comment = create_comment(a_discussion)
            a_discussion.comments << a_comment
          end
          discussions << a_discussion
        end
        h[:discussions] = discussions

        #create some motions
        motions = []
        (0..rand(2)).each do |k|
          a_motion = create_motion(discussion)
          motions << a_motion
        end
        h[:motions] = motions

        @activity[group_i.full_name] = h
      end

      @since_time = Time.now - 10.hours

      addresses.each do |email|
        user.stub email: email
        Discussion.any_instance.stub number_of_comments_since: rand(13)
        UserMailer.daily_activity(user, @activity, @since_time).deliver
        puts " ~ SENT (#{email})"
      end
    end

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
        User.stub(:find_by_email).and_return(admin)
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
      motion.stub close_at: Time.now + 1.hour
      addresses.each do |email|
        user.stub email: email
        UserMailer.motion_closing_soon(user, motion).deliver
        puts " ~ SENT (#{email})"
      end
    end
  end
end
