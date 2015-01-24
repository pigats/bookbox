require 'sidekiq'

class BooksWorker
	include Sidekiq::Worker
	puts "BooksWorker included"
	def perform(name, count)
    puts 'Doing hard work'
  end
end