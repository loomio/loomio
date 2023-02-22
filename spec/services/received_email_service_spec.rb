require 'rails_helper'

describe ReceivedEmailService do
  describe 'strip subject' do
    it 'correctly strips re and fwd from subject lines' do
      [
        "Re: repairing the is fwd software",
        "Fwd: repairing the is fwd software",
        "RE: FW: repairing the is fwd software",
        "FW: RE: RE: repairing the is fwd software",
        " FW repairing the is fwd software",
        "RE repairing the is fwd software",
        "RE FWD: repairing the is fwd software",
        "RE: FW repairing the is fwd software",
      ].each do |line|
        expect(line.gsub(/^( *(re|fwd?)(:| ) *)+/i, '')).to eq "repairing the is fwd software"
      end
    end
  end
end

