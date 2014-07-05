class UsersController < ApplicationController

  before_action :login, only: [:top, :gender, :age]

  def index
    # if current_user
    #   redirect_to :action => 'top'
    # end
  end

  def about
  end

  def test
    save_fb_data
    render :json => 1
  end

  def top
    @colike = get_colike( fbdata['me']['likes'], fbdata['friends'])
      .values.sort{|a,b| b[:count] <=> a[:count]}
    @quotes = get_quotes( fbdata['friends'] ).values.sort_by{rand}
    @myimage = fbdata['me']['image']
    @pagename = fbdata['page']
  end

  def update
    save_fb_data
    redirect_to '/users', :notice => 'Facebookからデータを取得しました！'
  end

  def gender
    count = [
      { 'gender' => '男性', 'population' => 0 },
      { 'gender' => '女性', 'population' => 0 },
      { 'gender' => '性別不明', 'population' => 0 }
    ]

    fbdata['friends'].each do |friend|
      case friend['gender']
      when 'male'
        count[0]['population'] += 1
      when 'female'
        count[1]['population'] += 1
      else
        count[2]['population'] += 1
      end
    end

    render :json => count
  end

  def age
    age_count = Hash.new(0)
    fbdata['friends'].each do |friend|
      next if friend['birthday'].nil?

      birthday = Date.new(
        friend['birthday']['year'],
        friend['birthday']['month'],
        friend['birthday']['day']
      )

      today = Date.today
      diff = today - Date.new(today.year, birthday.month, birthday.day)
      age = diff > 0 ? today.year - birthday.year : today.year - birthday.year - 1

      age_floor = (age / 10.0).floor * 10
      age_count[age_floor] += 1
    end

    data = Array.new
    age_count.each do |k, v|
      data.push({'age' => "#{k}代", 'population' => v})
    end

    render :json => data
  end

  private
    def login
      redirect_to '/auth/facebook' if !current_user
    end

    def fbdata
      save_fb_data if current_user.data.nil?
      @fbdata ||= JSON.parse current_user.data
    end

    def get_colike( mylikes, friends)
      data = Hash.new
      friends.each do |friend|
        next if friend['likes'].nil?

        colike_ids = mylikes & friend['likes']
        next if colike_ids.size == 0

        data[friend['uid']] = {
          :name   => friend['name'],
          :link   => friend['link'],
          :image  => friend['image'],
          :count  => colike_ids.size,
          :page   => colike_ids.map{ |id| id}
        }
      end

      return data
    end

    def get_quotes( friends )
      data = Hash.new
      friends.each do |friend|
        next if friend['quotes'].nil?
        data[friend['uid']] = {
          :name   => friend['name'],
          :link   => friend['link'],
          :image  => friend['image'],
          :quote  => friend['quotes']
        }
      end
      return data
    end

    def save_fb_page(user, likes)
      pages = user.fb_pages.build
      likes.each do |like|
        pages.pid = like['id']
        pages.name = like['name']
      end
      pages.save
    end

    def save_fb_data
      graph = Koala::Facebook::API.new(current_user.token)

      me = graph.get_object('me?fields=birthday,picture')
      user = current_user.build_fb_user
      user.image_url = me['picture']['data']['url']
      user.birthday = me['birthday']
      user.save
      save_fb_page(user, graph.get_connections("me", "likes?fields=name,id"))

      friends = graph.get_connections("me", "friends?fields=id,name,link,birthday,picture,likes,gender,quotes")
      friends.each do |friend|
        u = User.find_by uid: friend['id']
        if u.nil?
          u = User.new(
            :uid        => friend['id'],
            :name       => friend['name'],
            :gender     => friend['gender'],
            :quotes     => friend['quotes'],
            :image_url  => friend['picture']['data']['url'],
            :birthday   => friend['birthday']
          )
          save_fb_page(u, friend['likes']['data'])
        end
        f = user.fb_friends.build
        f.fb_friend_id = u.uid
        f.save
      end

    end
end
