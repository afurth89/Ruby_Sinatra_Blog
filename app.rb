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

  def word_count
    word_count = text.split(" ").length
  end

  def avg_word_length
    total_chars = 0
    words_array = text.split(" ")
    words_array.each do |word|
      total_chars += word.length
    end
    avg_length = '%.2f' % (total_chars.to_f/words_array.length)
  end

  # From http://blog.mccartie.com/2013/08/19/word-count-exercise.html
  def word_usage
    prep_words_for_counting()
    # Creates new hash, every value set to zero
    word_list = Hash.new(0)
    text.downcase.split(" ").each do |word|
      # Pass each word to helper func
      # Return updated word list with count for each word
      word_list = process_word_in_list(word, word_list)
    end
    word_list
  end

  def most_popular_word
    word_list = word_usage
    popular_word = {}
    popular_word['word'] = ""
    popular_word['count'] = 0
    word_list.each do |word, count|
      if count > popular_word['count']
        popular_word['word'] = word
        popular_word['count'] = count
      end
    end
    popular_word
  end

private
  def process_word_in_list(word, word_list)
    word = parse_word(word)
    return word_list if word.empty?
    # Increment count by 1
    word_list[word] += 1
    word_list
  end

  def prep_words_for_counting
    # Replace all periods and commas with spaces - which will be removed later
    text.gsub!(",", " ")
    text.gsub!(".", " ")
  end

  def parse_word(word)
    # Remove anything that is not a letter or number
    word.gsub!(/[^a-zA-Z0-9]/, "")
    word
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
  @length = analytics.word_count
  @avg_length = analytics.avg_word_length
  @word_list = analytics.word_usage
  @most_popular = analytics.most_popular_word
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