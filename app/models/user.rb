class User < ActiveRecord::Base

  has_many :likes

  # attr_accessible :provider, :uid, :name

  # validates :provider, presence: :true
  # validates :uid, presence: :true
  # validates :name, presence: :true

  # validates_uniqueness_of :uid, scope: :provider

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid      = auth["uid"]
      user.name     = auth['info']['name']
      user.email    = auth['info']['image']
      user.image    = auth['info']['email']
      user.token    = auth['credentials']['token']
    end
  end

end
