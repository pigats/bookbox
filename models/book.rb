class Book
	include Mongoid::Document
	include Mongoid::Timestamps

	field :title, type: String

	index({title: 1})
end
