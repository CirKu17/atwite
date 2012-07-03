#!/usr/bin/env ruby

require 'yaml'


def write(title,tags,commits,description)

  File.open('point.yaml', 'w') do |out|
  
  out.write(
      { 'title' => title ,
        'tags' => tags ,
        'commits' => commits ,
        'description' => description }.to_yaml )
  
  end

end

def read
  
  abort("Point file not found, have you initialized the repo?")  if !File.exists?( "point.yaml") 
  doc = YAML::load( File.open( "point.yaml") )
  
  return doc
end

def init(title)
  
  tags = Array.new
  puts "Add tags (end with empty line)"
  until tags.last == ""
    tags << STDIN.gets.chomp
  end
  tags.pop
  
  puts "Add description"
  description = STDIN.gets
  
  write(title,tags,[],description)
end

def commit(userid)
  puts "Commit message: "
  new_commit = "#{Time.now.strftime("%F %T")}" + " #{userid} :" + " #{STDIN.gets.chomp}"
  title = read['title']
  tags = read['tags']
  commits = read['commits'].unshift(new_commit)
  description = read['description']
  write(title,tags,commits,description)
end


unless ARGV.empty? 
  if ARGV.first == "write"
    write(title,tags,commits,description)
  elsif ARGV.first == "read"
    point = read
  elsif ARGV.first == "init"
    init(ARGV[1])
  elsif ARGV.first == "commit"
    commit(ARGV[1])
  end
else
  abort("No proper arguments passed")
end

