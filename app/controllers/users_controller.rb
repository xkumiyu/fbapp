class UsersController < ApplicationController

  before_action :login, only: [:top, :gender, :age]

  def index
  end

  def top
    @colike = get_colike( fbdata['me']['likes'], fbdata['friends'], fbdata['page'] )
      .values.sort{|a,b| b[:count] <=> a[:count]}
    @quotes = get_quotes( fbdata['friends'] ).values.sort_by{rand}
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

    def get_colike( mylikes, friends, page )
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
          :page   => colike_ids.map{ |id| page[id] }
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

    def save_fb_data
      current_user.data = JSON.generate get_fb_data
      current_user.save
    end

    def get_fb_data
      data = Hash.new
      graph = Koala::Facebook::API.new(current_user.token)
      Koala.config.api_version = "v1.0"

      me = graph.get_object('me?fields=birthday,picture')
      data[:me] = {:image => me['picture']['data']['url']}
      if !me['birthday'].nil? and me['birthday'] =~ /(\d{2})\/(\d{2})\/(\d{4})/
        data[:me][:birthday] = {
          :year   => $3.to_i,
          :month  => $1.to_i,
          :day    => $2.to_i
        }
      end

      data[:page] = Hash.new
      graph.get_connections("me", "likes?fields=name,id").each do |like|
        data[:page][like['id']] = like['name']
      end
      data[:me][:likes] = data[:page].keys

      friends = graph.get_connections("me", "friends?fields=id,name,link,birthday,picture,likes,gender,quotes")
      data[:friends] = Array.new
      friends.each do |friend|
        f = {
          :uid    => friend['id'],
          :name   => friend['name'],
          :link   => friend['link'],
          :gender => friend['gender'],
          :quotes => friend['quotes'],
          :image  => friend['picture']['data']['url']
        }

        f[:likes] = friend['likes']['data'].map { |row| row['id'] } if !friend['likes'].nil?

        if !friend['birthday'].nil? and friend['birthday'] =~ /(\d{2})\/(\d{2})\/(\d{4})/
          f[:birthday] = {
            :year   => $3.to_i,
            :month  => $1.to_i,
            :day    => $2.to_i
          }
        end

        data[:friends].push f
      end

      return data
    end
end
