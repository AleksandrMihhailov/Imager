#! /usr/bin/env ruby

require 'Mysql2'
require 'yaml'
require 'FileUtils'

DS = File::Separator

config = ['..', 'application', 'app', 'config.admin.yml']
config = YAML.load_file config.join DS

db = Mysql2::Client.new(
    host: config['database']['hostname'],
    username: config['database']['username'],
    password: config['database']['password'],
    database: config['database']['database']
)

fileDir = ['..', 'application', 'storage', 'gallery'].join DS
destDir = ['..', 'application', 'storage', 'products'].join DS
count = 0

products = db.query 'SELECT * FROM gallery WHERE type = \'product\''
puts products.count
products.each do |product|
    if File.exist? fileDir + DS + product['file'] + '.' + product['ext']

        originFile = fileDir + DS + product['file'] + '.' + product['ext']
        copiedFile = destDir + DS + product['file'] + '.' + product['ext']

        FileUtils.cp originFile, copiedFile
        puts product['file'] + '.' + product['ext'] + ' copied!'
        count += 1
    end
end
puts 'Count: ' + count.to_s
