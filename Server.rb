#!/usr/bin/env ruby

require 'socket'
require 'Mysql2'
require 'yaml'

DS = File::Separator
webServer = TCPServer.new 'localhost', 3000

config = ['..', 'application', 'app', 'config.admin.yml']
config = YAML.load_file config.join DS

db = Mysql2::Client.new(
    :host     => config['database']['hostname'],
    :username => config['database']['username'],
    :password => config['database']['password'],
    :database => config['database']['database']
)

galleryFabrics = db.query 'SELECT file FROM gallery WHERE type = \'fabric\''

while(session = webServer.accept)
    
    puts session.gets
    session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"
    session.write '<center>' + Time.now.to_s + '</center>'
    session.write '<br>'
    session.print '<center>Hello, World!</center>'
    session.close
end
