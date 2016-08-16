# app.rb

require 'sinatra'
require 'sinatra/activerecord'
require './environments'

class Post < ActiveRecord::Base
end


helpers do
  def title
    if @title
      "#{@title}"
    else
      "Welcome"
    end
  end
end

get "/" do
  @posts = Post.order("created_at DESC")
  @title = "Welcome"
  erb :"posts/index"
  # "Hello World"
end

get "/posts/:id" do
  @post = Post.find(params[:id])
  @title = @post.title
  erb :"posts/view"
end