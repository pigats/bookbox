class User
	include Mongoid::Document
	include Mongoid::Timestamps #created_at, updated_at

	field :name, type: String
	field :email, type: String
	
	field :dropbox_id, type: String
	field :dropbox_token, type: String

	field :genres, type: Array

	field :current_book, type: Hash
	field :read_books, type: Array
	field :unliked_books, type: Array

	index({email: 1}, {unique: true})
	index({dropbox_id: 1}, {unique: true})


	#randomly find the next book which is not current_book
	#or in the read_books, unliked_books 

	def next_unread_book()
	end

	#uploads to dropbox the next unread book
	#and sets it as current_book
	#it uses 'next_unread_book'
	#
	# current_book_state (did the user like it?)
	# :read -> the book goes to read_books {_id: book.id, read_at:, started_at:} 
	# :unliked -> the book goes to unliked_books
	def upload_next_unread_book(current_book_state=:read)
	end



end
