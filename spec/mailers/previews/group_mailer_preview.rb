class GroupMailerPreview < ActionMailer::Preview
  def membership_request
    group = FactoryGirl.create(:formal_group)
    membership_request = MembershipRequest.new(group: group,
                                               introduction: "Hi please let me in, I'm relevant")
    user = FactoryGirl.create(:user)
    membership_request.requestor = user
    membership_request.save!
    GroupMailer.membership_request(group.admins.first, membership_request)
  end

  def group_email
    group = FactoryGirl.create(:formal_group)
    sender = group.admins.first
    subject = "Please be aware of the important decision we're making"
    message = "as you all know the things have been happening and we need full engagement for the next thing so please come join us"
    recipient = FactoryGirl.create(:user)
    GroupMailer.group_email(group, sender, subject, message, recipient)
  end
end
