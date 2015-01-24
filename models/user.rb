class User
	include Mongoid::Document
	include Mongoid::Timestamps #created_at, updated_at

	field :name, type: String
	field :email, type: String
	
	field :dropbox_id, type: String
	field :dropbox_token, type: String

	field :read_books, type: Array
	field :unliked_books, type: Array
	
	index({email: 1}, {unique: true})
	index({dropbox_id: 1}, {unique: true})


end
