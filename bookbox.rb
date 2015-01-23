require 'sinatra'
require 'sinatra/asset_pipeline'

class BookBox < Sinatra::Base
  register Sinatra::AssetPipeline  

  get '/' do 
    @auth_url = 'https://www.dropbox.com/1/oauth2/authorize?client_id=0335l2g1v7ujyaa&response_type=code'

    haml :index
  end

  get 'auth/dropbox' do 
    params.inspecs
  end


end
