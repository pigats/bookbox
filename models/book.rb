class Book
	include Mongoid::Document
	include Mongoid::Timestamps

	field :title, type: String
	field :genres, type: Array
	field :author_name, type: String
	field :pages, type: Integer
	field :date, type: Date

	index({title: 1})
	index({genres: 1})

end
