class UsersController < ApplicationController

  def calc
    graph = Koala::Facebook::API.new(current_user.access_token)

    @likes = graph.get_connections('me', 'likes')

    # my_likes = Hash.new
    # graph.get_connections("me", "likes?fields=name,id").each do |like|
    #   my_likes[like['id']] = like['name']
    # end

    # friends = Array.new
    # graph.get_connections("me", "friends?fields=id,likes").each do |friend|
    #   if !friend['likes'].nil?
    #     friends.push({
    #       :friend_id => friend['id'],
    #       :like_ids => friend['likes']['data'].map { |row| row['id'] }
    #     })
    #   end
    # end

    # co_likes = Hash.new
    # friends.each do |friend|
    #   co_like_ids = my_likes.keys & friend[:like_ids]
    #   co_likes[friend[:friend_id]] = {
    #     :count => co_like_ids.size,
    #     :like_name => co_like_ids.map { |co_like_id| my_likes[co_like_id] }
    #   }
    # end


  end

end
