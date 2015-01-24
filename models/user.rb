class User
	include Mongoid::Document
	include Mongoid::Timestamps #created_at, updated_at

	field :name, type: String
	field :email, type: String
	
	field :dropbox_id, type: String
	field :dropbox_token, type: String
	field :dropbox_locale, type: String

	field :genre, type: String

	embeds_one :current_book, class_name: 'Book'
	embeds_many :read_books, class_name: 'Book'
	embeds_many :unliked_books, class_name: 'Book'
	


	index({email: 1}, {unique: true})
	index({dropbox_id: 1}, {unique: true})

	def dropbox_client
		DropboxClient.new(self.dropbox_token)
	end

	#randomly find the next book which is not current_book
	#or in the read_books, unliked_books 
	def next_unread_book
		books = Book
		if not self.genre.nil?
			genre_regex = Regexp.quote(self.genre)
			book_tag_regex = /(\s+|^)#{genre_regex}(\s+|$)/i
			books = books.in({genres: [book_tag_regex]})
		end

		if self.read_books.count() > 0
			books = books.where(_id: {'$nin' => self.read_books.pluck('_id')})
		end

		if self.unliked_books.count() > 0
			books = books.where(_id: {'$nin' => self.unliked_books.pluck('_id')})
		end

		books.first()
	end

	#uploads to dropbox the next unread book
	#and sets it as current_book
	#it uses 'next_unread_book'
	#
	# current_book_state (did the user like it?)
	# :read -> the book goes to read_books {_id: book.id, read_at:, started_at:} 
	# :unliked -> the book goes to unliked_books
	def upload_next_unread_book(current_book_state=:read)

		if current_book_state == :read
			self.read_books << self.current_book
		elsif current_book_state == :unliked
			self.unliked_books << self.current_book
		end
		self.save!

		book = next_unread_book
		upload_book(book)
	end

	def upload_book(book)
		client = dropbox_client
		epub_url = book.epub_url
		title = book.title.gsub("\n","\s").gsub("\r","")

		client.put_file("#{title}.epub",open(epub_url))
		self.current_book = book
		self.save!
	end

	def create_dirs
		client = dropbox_client
		begin
			client.file_create_folder 'read'
		rescue
		end
	end

end
