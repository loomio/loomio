require 'rails_helper'

describe API::UsageReportsController do
  it 'create' do
    expect {post(:create, params: {
                                   usage_report: {groups_count:1,
                                                                  users_count: 1,
                                                                  visits_count:1,
                                                                  canonical_host: "localhost"}
    })}.to change {UsageReport.count}.by(1)
    expect(response.code).to eq "200"
    expect(UsageReport.last.groups_count).to eq 1
  end

  # can't acutally test this in a spec
  # it 'send' do
  #   expect {UsageReportService.send}.to change {UsageReport.count}.by(1)
  # end
end
