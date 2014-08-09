class Page < ActiveRecord::Base

  belongs_to :user

  validates :fbid, presence: :true
  validates :name, presence: :true
  

  def url
    return "http://www.facebook.com/" + self.fbid
  end

end
