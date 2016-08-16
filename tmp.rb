# app.rb

require 'sinatra'

get "/" do
  #@posts = Post.order("created_at DESC")
  #@title = "Welcome"
  # erb :"posts/index"
  "Hello World"
end