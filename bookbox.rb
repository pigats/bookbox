require 'sinatra'
require 'sinatra/asset_pipeline'
require 'dropbox_sdk'
require 'pry'

class BookBox < Sinatra::Base
  register Sinatra::AssetPipeline  
  enable :sessions
  
  def dropbox_auth_flow
    DropboxOAuth2Flow.new(ENV['DROPBOX_KEY'], ENV['DROPBOX_SECRET'], url('/signup/dropbox'), session, :dropbox_auth_csrf_token) 
  end

  get '/' do 
    @auth_url = dropbox_auth_flow.start 
    haml :index
  end

  get '/signup/dropbox' do 
    access_token, user_id, url_state = dropbox_auth_flow.finish(params)
    #save user
    session[:dropbox_token] = access_token
    redirect url('/signup/genre')
  end

  get '/signup/genre' do 
    DropboxClient.new(session[:dropbox_token]).put_file('/test.jpg', open('./test.jpg'))  
    'yay'
  end

end
