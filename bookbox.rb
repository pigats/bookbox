require 'compass'
require 'susy'
require 'coffee-script'

require 'sinatra'
require 'sinatra/asset_pipeline'
require 'dropbox_sdk'
require 'mongoid'
require 'resque'
require 'redis'
require 'open-uri'

require './models/user'
require './models/book'


require 'json'

class BookBox < Sinatra::Base
  register Sinatra::AssetPipeline  
  enable :sessions

  configure do
    Mongoid.load!('mongoid.yml', environment)
  end

  def dropbox_auth_flow
    DropboxOAuth2Flow.new(ENV['DROPBOX_KEY'], ENV['DROPBOX_SECRET'], url('/signup/dropbox'), session, :dropbox_auth_csrf_token) 
  end

  get '/' do 
    @signup_stage = 'signup'
    @auth_url = dropbox_auth_flow.start 
    haml :index
  end

  get '/signup/dropbox' do 
    access_token, user_id, url_state = dropbox_auth_flow.finish(params)
    #save user
    session[:dropbox_token] = access_token
    
    #check if the user exists
    @user = User.find_or_create_by(dropbox_id: user_id)

    #get the user details
    user_info = DropboxClient.new(session[:dropbox_token]).account_info()
    @user.dropbox_token = session[:dropbox_token]
    if user_info
      @user.name = user_info['display_name']
      @user.email = user_info['email']
      @user.dropbox_locale = user_info['locale']
    end
    @user.save
    @user.create_dirs
    session[:user_id] = @user._id
    redirect url('/signup/genre')
  end

  get '/signup/genre' do 
    @user = User.find(session[:user_id])
    @signup_stage = 'choose_genre'
    haml :index
  end

  get '/users/update' do
    params[:challenge]
  end
  
  get '/users/thanks' do 
    @signup_stage = 'finished'
    haml :index
  end

  post '/users/update' do
    json = JSON.parse(request.body.string)  
    delta = json['delta']
    users = delta['users']
    
  end

end
