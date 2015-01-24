class User
	include Mongoid::Document
	include Mongoid::Timestamps #created_at, updated_at

	field :name, String
	field :email, String
	field :dropbox_id, String
	field :dropbox_token, String

end
