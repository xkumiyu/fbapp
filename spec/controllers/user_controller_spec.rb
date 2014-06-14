require 'rails_helper'

RSpec.describe UserController, :type => :controller do
  describe 'get_fb_data' do
    @data = get_fb_data
  end
end
