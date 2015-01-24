class Book
	include Mongoid::Document
	include Mongoid::Timestamps

	field :gutenberg_id, type: String
	field :title, type: String
	field :genres, type: Array, default: []
	field :author, type: Hash, default: {}

	index({gutenberg_id: 1},{unique: 1})
	index({title: 1})
	index({genres: 1})
	
	def self.genres
		Book.pluck(:genres).flatten.uniq.sort {|a,b| a <=> b}
	end

end
