class User
	include Mongoid::Document
	include Mongoid::Timestamps #created_at, updated_at

	field :name, type: String
	field :email, type: String
	
	field :dropbox_id, type: String
	field :dropbox_token, type: String
	field :dropbox_locale, type: String
	field :dropbox_delta_cursor, type: String

	field :genre, type: String

	field :current_book_id, type: String
	field :read_books, type: Array, default: []
	field :unliked_books, type: Array, default: []
	


	index({email: 1}, {unique: true})
	index({dropbox_id: 1}, {unique: true})

	def self.someting_has_changed(dropbox_id)
		user = User.find_by dropbox_id: dropbox_id
		client = user.dropbox_client
		delta = client.delta(user.dropbox_delta_cursor)
		user.dropbox_delta_cursor = delta['cursor']
		user.save!

		delta['entries'] ||= []
		delta['entries'].each do |entry|
			path_components = File.split(entry[0])
			dir = path_components.first
			filename = path_components.last
			info = entry[1]
			if dir == '/' and filename == 'read'
				next
			end

			if info
				#file created/present
				if dir == '/read' and File.extname(filename) == '.epub'
					#file moved inside read dir saying was READ
					user.upload_next_unread_book(:read)
				end
			else
				if dir == '/' and File.extname(filename) == '.epub'
					#epub file deleted
					#we now provide a new one saying was UNLIKED
					user.upload_next_unread_book(:unliked)
				end
			end 
		end

		user.save!
	end

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
			books = books.where(_id: {'$nin' => self.read_books})
		end

		if self.unliked_books.count() > 0
			books = books.where(_id: {'$nin' => self.unliked_books})
		end

		if self.current_book_id
			books = books.where(_id: {'$nin' => [self.current_book_id]})
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
		
		if self.current_book_id
			if current_book_state == :read
				self.read_books << self.current_book_id
				self.read_books.uniq!
			elsif current_book_state == :unliked
				self.unliked_books << self.current_book_id
				self.unliked_books.uniq!
			end
			self.save!
		end
		

		book = next_unread_book
		upload_book(book)
	end

	def upload_book(book)
		client = dropbox_client
		epub_url = book.epub_url
		title = book.title.gsub("\n","\s").gsub("\r","")

		client.put_file("#{title}.epub",open(epub_url))
		self.current_book_id = book['_id']
		puts "CURRENT_BOOK: #{self.current_book_id}"
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
