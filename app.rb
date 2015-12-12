# url shortener, shamelessly adopted from
# http://code.tutsplus.com/tutorials/how-to-build-a-shortlink-app-with-ruby-and-redis--net-20984

require 'rubygems'
require 'sinatra'
require 'newrelic_rpm'
require 'sinatra/simple_auth'
require 'redis'

redis = Redis.new

enable :sessions
set :password, ENV['PASSWORD'] || 'pa$$word'
set :home, '/'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def random_string(length)
    rand(36**length).to_s(36)
  end
end

get '/login/?' do
  erb :login
end


get '/' do
  protected!
  erb :index
end

post '/' do
  protected!
  if params[:shortcode] and not params[:shortcode].empty?
    @shortcode = params[:shortcode]
  end
  if params[:url] and not params[:url].empty?
    @shortcode ||= random_string 5
    redis.setnx "links:#{@shortcode}", params[:url]
  end
  @shortened_url = ENV['BASEURL'] + "/#{@shortcode}"
  erb :index
end

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end
