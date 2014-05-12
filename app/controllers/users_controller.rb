class UsersController < ApplicationController

  before_action :fb_data, only: [:age, :colike, :gender, :quotes]

  # def create
  # end

  def index
  end

  def age
    age_count = Hash.new(0)
    @fb_data[:friends].each do |friend|
      next if friend[:birthday].nil?

      birthday = Date.new(
        friend[:birthday][:year],
        friend[:birthday][:month],
        friend[:birthday][:day]
      )

      today = Date.today
      diff = today - Date.new(today.year, birthday.month, birthday.day)
      age = diff > 0 ? today.year - birthday.year : today.year - birthday.year - 1

      age_floor = (age / 10.0).floor * 10
      age_count[age_floor] += 1
    end

    data = Array.new
    age_count.each do |k, v|
      data.push({'age' => k, 'population' => v})
    end

    render :json => data
  end

  def colike
    @co_likes = Array.new
    @fb_data[:friends].each do |friend|
      next if friend[:likes].nil?
      co_like_ids = @fb_data[:me][:likes] & friend[:likes]
      @co_likes.push({
        :uid        => friend[:uid],
        :name       => friend[:name],
        :image      => friend[:image],
        :count      => co_like_ids.size,
        :like_name  => co_like_ids.map { |co_like_id| @fb_data[:page][co_like_id] }
      })
    end
  end

  def gender
    @male_count ||= 0
    @female_count ||= 0
    @unknown_count ||= 0

    @fb_data[:friends].each do |friend|
      @male_count += 1 if friend[:gender] == "male"
      @female_count += 1 if friend[:gender] == "female"
      @unknown_count +=1 if (friend[:gender] != "male" && friend[:gender] != "female")
    end
  end

  def quotes
    @words = Array.new
    @fb_data[:friends].each do |friend|
      next if friend[:quotes].nil?
      @words.push({
        :uid        => friend[:uid],
        :name       => friend[:name],
        :image      => friend[:image],
        :quotes     => friend[:quotes]
      })
    end
  end

  private
    def fb_data
      @fb_data ||= get_fb_data
    end

    def get_fb_data
      data = Hash.new
      graph = Koala::Facebook::API.new(current_user.token)

      data[:page] = Hash.new
      graph.get_connections("me", "likes?fields=name,id").each do |like|
        data[:page][like['id']] = like['name']
      end
      data[:me] = {
        :likes => data[:page].keys
      }

      friends = graph.get_connections("me", "friends?fields=id,name,birthday,picture,likes,gender,quotes")
      data[:friends] = Array.new
      friends.each do |friend|
        f = {
          :uid    => friend['id'],
          :name   => friend['name'],
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
