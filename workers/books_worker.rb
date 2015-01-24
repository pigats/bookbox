require 'sidekiq'

class BooksWorker
	include Sidekiq::Worker
	puts "BooksWorker included"
	def perform(user_id, webhook_hash)
    puts 'Doing hard work'
  end
end