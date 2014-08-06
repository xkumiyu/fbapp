class UsersController < ApplicationController

  before_action :login, only: [:top, :gender, :age]

  def index
    # if current_user
    #   redirect_to :action => 'top'
    # end
  end

  def about
  end

  def top
    @quotes_friends = current_user.friends_user.select{ |row| !row.quotes.nil? }.shuffle.first(10)

    my_likes = current_user.pages.map{|row| row.id}
    @colike_friends = Array.new
    current_user.friends_user.each do |friend|
      friend_likes = friend.pages.map{|row| row.id}
      ids = my_likes & friend_likes
      next if ids.size < 1
      @colike_friends << {
        :friend => friend,
        :co_ids => ids,
      }
    end
    @colike_friends = @colike_friends.sort_by{|row| row[:co_ids].size * -1}.first(10)
  end

  def update
    get_fb_data
    redirect_to '/users', :notice => 'Facebookからデータを取得しました！'
  end

  def gender
    count = [
      { 'gender' => '男性', 'population' => 0 },
      { 'gender' => '女性', 'population' => 0 },
      { 'gender' => '性別不明', 'population' => 0 }
    ]

    current_user.friends_user.each do |friend|
      case friend.gender
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
    current_user.friends_user.each do |friend|
      next if friend.birthday.nil?

      age_floor = (friend.age / 10.0).floor * 10
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

      current_user.update_user( graph.get_object('me?fields=birthday,picture') )
      current_user.save
      save_pages( current_user, graph.get_connections("me", "likes?fields=name,id") )

      friends = graph.get_connections("me", "friends?fields=id,name,link,birthday,picture,likes,gender,quotes")
      friends.each do |friend|
        user = User.find_or_create_by( uid: friend['id'] ) do |user|
          user.update_user( friend )
        end
        Friend.find_or_create_by(user_id: current_user.id, friend_id: user.id)

        next if friend['likes'].nil?
        next if friend['likes']['data'].nil?
        save_pages( user, friend['likes']['data'] )
      end
    end
end
