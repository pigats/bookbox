require 'sinatra'
require 'sinatra/asset_pipeline'
require 'dropbox_sdk'

class BookBox < Sinatra::Base
  register Sinatra::AssetPipeline  
  enable :session
 
  get '/' do 
    flow =  DropboxOAuth2Flow.new(ENV['DROPBOX_KEY'], ENV['DROPBOX_SECRET'], url('/auth/dropbox'), session, :csrf_token_session_key) 
    session[:flow] = flow
    @auth_url = flow.start 
    haml :index
  end

  get '/auth/dropbox' do 
    session[:flow]
    token = session[:flow].finish(params[:code])
    #return token
  end

  get '/env' do
    ENV['DROPBOX_KEY']
  end

end
