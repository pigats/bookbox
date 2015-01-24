require 'linkeddata'

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
    
    reader.each_triple do |s, p, o|
      puts "title: #{o}" if p == title_p
      puts "author name: #{o}" if p == author_p
      puts "birth: #{o}" if p == author_birth_p  
      puts "death: #{o}" if p == author_death_p
      puts "epub: OK" if p == format_p and o.to_s.include? 'epub'
      subjects_s << o if p == subject_p
    end
    
    print 'subjects: '
    reader.each_triple do |s, p, o|
      print "#{o}; " if subjects_s.include? s and p == value_p
    end 
    

  end
  puts
  puts '-----------'
end 
