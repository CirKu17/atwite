#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'

@dropbox_path="/home/cirku17/Dropbox"
@local_path= FileUtils.getwd

#writes on the point file
def write(title,tags,commits,description)

  File.open('point.yaml', 'w') do |out|
  
  out.write(
      { 'title' => title ,
        'tags' => tags ,
        'commits' => commits ,
        'description' => description }.to_yaml )  
  end

end

#reads the point file
def point_file
  
  abort("Point file not found, have you initialized the repo?")  if !File.exists?( "point.yaml") 
  doc = YAML::load( File.open( "point.yaml") )
  
  return doc
end

#initializes the local and remote repos
def init
  
  puts "User ID: "
  userid = STDIN.gets.chomp
  puts "Project Title: "
  title = STDIN.gets.chomp
  
  if check_component("config", :condition => true) || check_component("remote_repo", :repo_name => title, :condition => true)
    abort 'Already initialized repo, use flush or remove to initialize again'
  end
  FileUtils.mkdir 'atwite_config' 
  FileUtils.mkdir "#{@dropbox_path}/#{title}"
  
  File.open('atwite_config/config', 'w') { |file| file.write("#{title}\n#{userid}") }
  
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

#adds a commit to the point file
def commit
  userid=read_config_line(2)
  puts "Commit message: "
  new_commit = "#{Time.now.strftime("%F %T")}" + " #{userid} :" + " #{STDIN.gets.chomp}"
  title = point_file['title']
  tags = point_file['tags']
  commits = point_file['commits'].unshift(new_commit)
  description = point_file['description']
  
  write(title,tags,commits,description)
end

#adds local files to index
def add
  ARGV.each_with_index { |x,i|
    if File.exists?(ARGV[i+1])
      File.open('atwite_config/index', 'a') { |file| file.write("#{ARGV[i+1]}\n") }
    else
      abort ("File #{ARGV[i+1]} does not exist")
    end
  }
end

#copies files added to index to remote repo dir
def push
  check_component("config")
  title = read_config_line(1)
  files = IO.readlines("#{@local_path}/atwite_config/index")
  files.each { |file|
    file=file.chomp
    if File.exists?(file)
      FileUtils.cp(file,"#{@dropbox_path}/#{title}")
    else
      abort "File: #{file} does not exist"
    end
  }
end

#removes local repo files
def flush
  check_component("pointfile", :interrupt => false)
  FileUtils.rm("#{@local_path}/point.yaml")
  
  check_component("config")
  FileUtils.rmdir("#{@local_path}/atwite_config")
end

#removes local and remote repo files
def remove
  flush
  
  title = read_config_line(1)
  check_component("remote_repo", :repo_name => title)
  FileUtils.rmdir("#{@dropbox_path}/#{title}")
end

#copies in local_path the specified remote repo
def clone
  puts "What's the name of the repo to clone?"
  title = STDIN.gets
  
  check_component("remote_repo", :remote_name => title)
  FileUtils.cp_r("#{@dropbox_path}/#{repo}",@local_path)
end

#generates a .html version of the point file
def generate_html
  check_component("pointfile")  
  fileHtml = File.new("point.html", "w+")
  fileHtml.puts "
  <!DOCTYPE html><html><body>
  <title>#{point_file['title']}</title>
  <h1>#{point_file['title']}</h1>
  <i>#{point_file['description']}</i>
  <h2>Tags</h2>
  <p>"
  point_file['tags'].each do |tag|             
    fileHtml.puts "#{tag}"
  end
  fileHtml.puts "
  </p>
  <h2>Commits</h2>
  <ul>"
  point_file['commits'].each do |commit|             
    fileHtml.puts "<li>#{commit}</li>"
  end  
  fileHtml.puts "</ul></body></html>"
  fileHtml.close()
  
end

#returns the specified line of config
def read_config_line(number)
  lines = IO.readlines("#{@local_path}/atwite_config/config")
  return lines[number-1].chomp
end

#checks component existence
#ids are: pointfile, config, index, remote_repo
#options are: repo_name => <name> (required if remote_repo is specified as id)
#             verbose   : prints out a message (default is true)
#             interrupt : abort at end (default is true)
#             condition : makes method only return a bool (true if component exists) (default is false)
def check_component(id, options = {})
  repo_name = options[:repo_name]
  verbose   = options[:verbose]   || true
  interrupt = options[:interrupt] || true
  condition = options[:condition] || false

  if condition
    verbose = false
    interrupt = false
  end
  
  flag = true
  
  if id=="pointfile" && !File.exists?("#{@local_path}/point.yaml")
    puts "No point file found" if verbose
    flag = false
  elsif id=="config" && !File.exists?("#{@local_path}/atwite_config/config")
    puts "No config dir found" if verbose
    flag = false
  elsif id=="index" && !File.exists?("#{@local_path}/atwite_config/index")
    puts "No index file found" if verbose
    flag = false
  elsif id=="remote_repo" 
    if defined?(repo_name) && !File.exists?("#{@dropbox_path}/#{repo_name}")
      puts "No remote repo named #{repo_name} found" if verbose
      flag = false
    elsif !defined?(repo_name)
      puts "No repo name provided"
    end
  end
  
  interrupt ? (abort "Aborting") : (return flag)
  
end

def test
  puts 'test'
end

usage = "
  init :  initialize new repo
  add :   add files to the indexing list
  push :  copy the files on the indexing list to Dropbox repo
  commit: add a commit to the point file
  flush:  delete local repo files
  remove: delete local repo files and Dropbox folder
  clone:  copy a repo from Dropbox to local folder
  generate_html:  generate an html file from the local point file
  
  "

methods=['test','init','add','push','commit','flush','remove','clone','generate_html']

unless ARGV.empty?
  methods.include?(ARGV.first) ? self.send(ARGV.first) : (puts "No proper arguments passed\n#{usage}")
else
  puts "No proper arguments passed\n#{usage}"
  abort
end


#
#unless ARGV.empty? 
#  if ARGV.first == "write"
#    write(title,tags,commits,description)
#  elsif ARGV.first == "read"
#    point = read
#  elsif ARGV.first == "init"
#    init
#  elsif ARGV.first == "add"
#    add
#  elsif ARGV.first == "push"
#    push
#  elsif ARGV.first == "commit"
#    commit
#  elsif ARGV.first == "flush"
#    flush
#  elsif ARGV.first == "remove"
#    remove
#  elsif ARGV.first == "clone"
#    clone    
#  elsif ARGV.first == "generate-html"
#    generate_html    
#  end
#else
#  abort("No proper arguments passed")
#end