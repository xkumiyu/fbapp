class FbUser < ActiveRecord::Base

  belongs_to :user
  has_many   :fb_pages
  has_many   :fb_friends

end
