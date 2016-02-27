#! /usr/bin/env ruby

require 'RMagick'
require 'Mysql2'
require 'yaml'

require './Image'

# defining directory separator
DS = File::Separator

# loading config
config = ['..', 'application', 'app', 'config.admin.yml']
config = YAML.load_file config.join DS

# connecting to mysql
db = Mysql2::Client.new(
    :host     => config['database']['hostname'],
    :username => config['database']['username'],
    :password => config['database']['password'],
    :database => config['database']['database']
)

# help method
def help
    puts "\n======== Help =========\n"
    puts "-f     *** fabrics"
    puts "-g     *** gallery"
    puts "-m     *** manuals"
    puts "-h     *** this message"
    puts "--help *** this message"
    puts "\n=======================\n"
end

if ARGV.length == 0
    # display main information
    fabrics = db.query('SELECT COUNT(*) AS count FROM fabrics').first
    gallery = db.query('SELECT COUNT(*) AS count FROM gallery').first
    manuals = db.query('SELECT COUNT(*) AS count FROM manuals_steps').first
    puts "Fabrics: #{fabrics['count']}"
    puts "Gallery: #{gallery['count']}"
    puts "Manuals: #{manuals['count']}"
    puts "Total: #{fabrics['count'] + gallery['count'] + manuals['count']}"
else
    
    # get console line arguments
    ARGV.each do |argument|
        case argument

        when '--check-products'
            puts "\n======= Checking products =======\n"
            require './ProductsCheck'
            ProductsCheck.new db

        when '--check-materials'
            puts "\n======= Checking materials =======\n"
            require './MaterialsCheck'
            MaterialsCheck.new db

        when '--materials-hunter'
            puts "\n======= Materials Hunter =======\n"
            require './MaterialsHunter'
            MaterialsHunter.new db

        when '--process-materials'
            puts "\n======= Processing Materials =======\n"
            require './ProcessMaterials'
            ProcessMaterials.new db

        when '-f'
            puts "\n======= Fabrics Action =======\n"
            require './Fabrics'
            Fabrics.new db
        when '-g'
            puts "\n======= Gallery Action =======\n"
            require './Gallery'
            Gallery.new db
        when '-p'
            puts "\n======= Products Action ========\n"
            require './Products'
            Products.new db
        when '-m'
            puts "\n======= Manuals action =======\n"
            require './Manuals'
            Manuals.new db
        when '--help'
            help
        when '-h'
            help
        else
            help
        end
    end

end
