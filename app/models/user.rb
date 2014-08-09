class User < ActiveRecord::Base

  has_and_belongs_to_many :pages
  has_many :friends

  # attr_accessible :provider, :uid, :name

  validates :provider, presence: :true
  validates :uid, presence: :true
  validates :name, presence: :true

  validates_uniqueness_of :uid, scope: :provider

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid      = auth["uid"]
      user.name     = auth['info']['name']
      user.token    = auth['credentials']['token']
    end
  end

  def update_user(data)
    self.uid       = data['id']                     || self.uid
    self.name      = data['name']                   || self.name
    self.gender    = data['gender']                 || self.gender
    self.quotes    = data['quotes']                 || self.quotes
    self.image_url = data['picture']['data']['url'] || self.image_url
    if data['birthday'] =~ /(\d{2})\/(\d{2})\/(\d{4})/ # mm/dd/yyyy
      self.birthday = Date.new($3.to_i, $1.to_i, $2.to_i)
    end
    self.provider = 'facebook'
  end

  def friends_user
    User.find( self.friends.map{|row| row.friend_id} )
  end

  def url
    return "http://www.facebook.com/" + self.uid
  end

  def age
    d1 = self.birthday.strftime("%Y%m%d").to_i
    d2 = Date.today.strftime("%Y%m%d").to_i

    return (d2 - d1) / 10000
  end

end
