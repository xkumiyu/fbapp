class Page < ActiveRecord::Base

  belongs_to :user


  def url
    return "http://www.facebook.com/" + self.fbid
  end

end
