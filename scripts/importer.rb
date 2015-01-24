require 'linkeddata'
require 'mongoid'

require './models/user'
require './models/book'

Mongoid.load!('mongoid.yml', 'development')

cache_path = ARGV[0]

paths = Dir.glob(File.join(cache_path, '/epub/*'));
title_p = 'http://purl.org/dc/terms/title'
author_p = 'http://www.gutenberg.org/2009/pgterms/name'
author_birth_p = 'http://www.gutenberg.org/2009/pgterms/birthdate'
author_death_p = 'http://www.gutenberg.org/2009/pgterms/deathdate'
subject_p = 'http://purl.org/dc/terms/subject'
value_p = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#value'
format_p = 'http://purl.org/dc/terms/hasFormat' 

paths.each do |path|
  id = path.split('/').last
  puts "ebook id: #{id}"

  RDF::Reader.open(File.join(path, "pg#{id}.rdf")) do |reader|

    subjects_s = [] 
    formats_s = [] 
    formats_value_s = [] 

    book = Book.new({gutenberg_id: id})
    has_epub = false
    reader.each_triple do |s, p, o|
      book.title = o.to_s if p == title_p
      book.author[:name] = o.to_s if p == author_p
      book.author[:dob] = o.to_i if p == author_birth_p  
      book.author[:dod] = o.to_i if p == author_death_p
      has_epub = true if p == format_p and o.to_s.include? 'epub'
      subjects_s << o if p == subject_p
    end

    if has_epub
      reader.each_triple do |s, p, o|
        book.genres << o.to_s if subjects_s.include? s and p == value_p
      end       
      book.save
    end

  end
  puts
  puts '-----------'
end 
