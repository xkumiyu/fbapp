class UsersController < ApplicationController

  # def create
  # end

  def index
  end

  def list
    data = [
      {
        "letter" => "A",
        "frequency" => ".08167"
      },
      {
        "letter" => "B",
        "frequency" => ".01492"
      },
      {
        "letter" => "Z",
        "frequency" => ".00074"
      }
    ]
    render :json => data
  end

  def age
    graph = Koala::Facebook::API.new(current_user.token)


    today = Date.today

    age_count = Hash.new(0)
    graph.get_connections("me", "friends?fields=id,name,birthday").each do |friend|
      next if friend['birthday'].nil?
      next if friend['birthday'] !~ /(\d{2})\/(\d{2})\/(\d{4})/

      birthday = Date.new($3.to_i, $1.to_i, $2.to_i)
      age = 0
      if today - Date.new(today.year, birthday.month, birthday.day) > 0
        age = today.year - birthday.year
      else
        age = today.year - birthday.year - 1
      end

      age_floor = (age / 10.0).floor * 10
      age_count[age_floor] += 1
    end

    # sum = age_count.values.inject(:+)
    # @age_rate = Hash.new
    # age_count.each do |k, v|
    #   @age_rate[k] = v / sum.to_f * 100
    # end

    data = Array.new
    age_count.each do |k, v|
      data.push({
        'age' => k,
        'population' => v
      })
    end

    render :json => data
  end

  def calc
    graph = Koala::Facebook::API.new(current_user.token)

    my_likes = Hash.new
    graph.get_connections("me", "likes?fields=name,id").each do |like|
        # fbpage = Fbpage.find_or_create_by(pid: like['id'], name: like['name'])
        # Like.find_or_create_by(user_id: current_user.id, fbpage_id: fbpage.id)
        my_likes[like['id']] = like['name']
    end

    @male_count ||= 0
    @female_count ||= 0
    @unknown_count ||= 0

    friends = Array.new
    graph.get_connections("me", "friends?fields=id,name,picture,likes,gender").each do |friend|
      if !friend['likes'].nil?
        friends.push({
          :user => {
            :id     => friend['id'],
            :name   => friend['name'],
            :image  => friend['picture']['data']['url'],
          },
          :like_ids => friend['likes']['data'].map { |row| row['id'] }
        })
      end
      @male_count += 1 if friend['gender'] == "male"
      @female_count += 1 if friend['gender'] == "female"
      @unknown_count +=1 if (friend['gender'] != "male" && friend['gender'] != "female")
    end

    @co_likes = Array.new
    friends.each do |friend|
      co_like_ids = my_likes.keys & friend[:like_ids]
      @co_likes.push({
        :friend     => friend[:user],
        :count      => co_like_ids.size,
        :like_name  => co_like_ids.map { |co_like_id| my_likes[co_like_id] }
      })
    end


  end

end
