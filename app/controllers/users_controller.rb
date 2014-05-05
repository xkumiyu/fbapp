class UsersController < ApplicationController

  # def create
  # end

  def calc
    graph = Koala::Facebook::API.new(current_user.token)

    my_likes = Hash.new
    graph.get_connections("me", "likes?fields=name,id").each do |like|
        # fbpage = Fbpage.find_or_create_by(pid: like['id'], name: like['name'])
        # Like.find_or_create_by(user_id: current_user.id, fbpage_id: fbpage.id)
        my_likes[like['id']] = like['name']
    end

    friends = Array.new
    graph.get_connections("me", "friends?fields=id,name,picture,likes").each do |friend|
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
