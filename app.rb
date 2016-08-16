require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions

class Post < ActiveRecord::Base
  validates :title, presence: true, length: { minimum: 5 }
  validates :body, presence: true
end

class Analytics
  attr_accessor :text

  def initialize(text)
    @text = text
  end

  def find_length
    @length = @text.length
  end
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

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# get all posts
get "/" do
  @posts = Post.order("created_at DESC")
  @title = "Welcome"
  erb :"posts/index"
  # "Hello World"
end

# create new post
get "/posts/create" do
  @title = "Create post"
  @post = Post.new 
  erb :"posts/create"
end

post "/posts" do
  @post = Post.new(params[:post])
  if @post.save
    redirect "posts/#{@post.id}", :notice => 'Congrats! Love the new post (This message will disappear in 4 seconds.)'
  else
    redirect "posts/create", :error => 'Something went wrong. Try again. (This message will disappear in 4 seconds.)'
  end
end

# get single post
get "/posts/:id" do
  @post = Post.find(params[:id])
  @title = @post.title
  analytics = Analytics.new(@post.body)
  @length = analytics.find_length
  erb :"posts/view"
end

# edit a post
get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Post"
  erb :"posts/edit"
end

put "/posts/:id" do 
  @post = Post.find(params[:id])
  @post.update(params[:post])
  redirect "posts/#{@post.id}"
end

# analytics
get "/analytics" do
  @posts = Post.order("created_at DESC")
  @title = "Analytics Page"
  erb :"analytics"
end