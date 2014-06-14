require 'rails_helper'

RSpec.describe User, :type => :model do
  describe 'create_with_omniauth' do
    before do
      user = User.new
      user.provider = 'facebook'
      user.uid      = '100003924155278'
      user.name     = 'tanaka tarou'
      user.token    = 'CAACi3xfj9HoBABFSjKB7LGlkJYqqYx68rJCml1RH3c7Sz5ZBbRkd0WgtLeFZC4S8IDrCnqpCPVMdp2gwlgDxIhRkNxJwCjjjen8nRrHbkkEtqRfXZCExmNxEOwFAlTZAtmCH8TBZCD340J0zDZBheeUBbN2syVQQxrToBuCxjgwYntVDxDoq60'
      @user = User.first
    end
  end

end
