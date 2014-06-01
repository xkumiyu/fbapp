class UsersController < ApplicationController

  before_action :login, only: [:top, :gender]

  def index
  end

  def top

    # render :json => fbdata['friends']

    render :json => quotes( fbdata['friends'] )
  # render :json => gender( fbdata['friends'] )
    # render :json => colike( fbdata['me']['likes'], fbdata['friends'], fbdata['page'] )
  end


  def gender
    count = Hash.new(0)
    fbdata['friends'].each do |friend|
      case friend['gender']
      when 'male'
        count[:male] += 1
      when 'female'
        count[:female] += 1
      else
        count[:unknown] += 1
      end
    end

    render :json => count
  end


  private
    def login
      redirect_to '/auth/facebook' if !current_user
    end

    def fbdata
      save_fb_data if current_user.data.nil?
      @fbdata ||= JSON.parse current_user.data
    end

    def colike( mylikes, friends, page )
      data = Hash.new
      friends.each do |friend|
        next if friend['likes'].nil?

        colike_ids = mylikes & friend['likes']
        next if colike_ids.size == 0

        data[friend['uid']] = {
          :count  => colike_ids.size,
          :page   => colike_ids.map{ |id| page[id] }
        }
      end

      return data
    end

    def quotes( friends )
      words = Hash.new
      friends.each do |friend|
        next if friend['quotes'].nil?
        words[friend['uid']] = friend['quotes']
      end
      return words
    end

    def save_fb_data
      current_user.data = JSON.generate get_fb_data
      current_user.save
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

  # def age
  #   age_count = Hash.new(0)
  #   @fb_data[:friends].each do |friend|
  #     next if friend[:birthday].nil?
  #
  #     birthday = Date.new(
  #       friend[:birthday][:year],
  #       friend[:birthday][:month],
  #       friend[:birthday][:day]
  #     )
  #
  #     today = Date.today
  #     diff = today - Date.new(today.year, birthday.month, birthday.day)
  #     age = diff > 0 ? today.year - birthday.year : today.year - birthday.year - 1
  #
  #     age_floor = (age / 10.0).floor * 10
  #     age_count[age_floor] += 1
  #   end
  #
  #   data = Array.new
  #   age_count.each do |k, v|
  #     data.push({'age' => k, 'population' => v})
  #   end
  #
  #   render :json => data
  # end
