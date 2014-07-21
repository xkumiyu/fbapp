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
    start_time = Time.now
    get_fb_data
    end_time = Time.now
    render :json => (end_time - start_time).to_s + "s"
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

    def get_colike(mylikes, friends)
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

    def save_user(user, data)
      user.uid       = data['id']                     || user.uid
      user.name      = data['name']                   || user.name
      user.gender    = data['gender']                 || user.gender
      user.quotes    = data['quotes']                 || user.quotes
      user.image_url = data['picture']['data']['url'] || user.uid
      user.birthday  = data['birthday']               || user.birthday
      user.save
    end

    def save_pages(user, likes)
      pages = Array.new
      likes.each do |like|
        pages << Page.find_or_create_by(fbid: like['id']){ |page| page.name = like['name'] }
      end
      user.pages = pages
      user.save
    end

    def get_fb_data
      graph = Koala::Facebook::API.new(current_user.token)

      save_user( current_user, graph.get_object('me?fields=birthday,picture') )
      save_pages( current_user, graph.get_connections("me", "likes?fields=name,id") )

      friends = graph.get_connections("me", "friends?fields=id,name,link,birthday,picture,likes,gender,quotes")
      friends.each do |friend|
        user = User.find_or_create_by( uid: friend['id'] )
        save_user( user, friend )
        next if friend['likes'].nil?
        next if friend['likes']['data'].nil?
        save_pages( user, friend['likes']['data'] )
      end
    end
end
