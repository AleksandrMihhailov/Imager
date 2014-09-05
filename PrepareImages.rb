#! /usr/bin/env ruby

require 'RMagick'
require 'Mysql2'
require 'yaml'

# load config
config = ['..', 'application', 'app', 'config.production.yml']
config = YAML.load_file config.join File::Separator
config[:crop] = false

# check RMagick gem
if defined?(RMagick)
    puts 'RMagick not installed!'
    exit
end

# check Mysql2 gem
if defined? Mysql
    puts 'Mysql not installed'
    exit
end

# connecting to mysql
db = Mysql2::Client.new(
    :host => config['database']['hostname'],
    :username => config['database']['username'],
    :password => config['database']['password'],
    :database => config['database']['database'],
    :encoding => config['database']['charset']
)

# fabrics main directory
fromDir = ['..', 'application', 'storage', 'fabrics', 'images']
fromDir = fromDir.join File::Separator

# directory to save result
toDir = ['..', 'content', 'img'].join File::Separator
wmFile = "..#{ds}application#{ds}watermarks#{ds}motiva600x600.png"

# watermark
wm = ['..', 'application', 'watermarks', 'motiva600x600.png']
wm = wm.join File::Separator
wm = Magick::Image.read(wm).first

# get and start action for each fabric
fabrics = db.query('select * from fabrics')
fabrics.each do |fabric|
    unless Dir.exist? fromDir + ds + fabric['image']

        puts fabric['image'] + ' ready!'

        #get image name
        imageName = fabric['image'].split('.')[0]

        # init file
        src = Magick::Image.read(fromDir + ds + fabric['image']).first

        # save origin image
        src.write "..#{ds}application#{ds}files#{ds}fabrics#{ds + imageName}"
        
        # thumbnail 60 x 60
        thumbnail60x60 = src.clone
        thumbnail60x60.scale! 60, 60
        thumbnail60x60.write "#{toDir + ds + imageName}-60x60.#{src.format.downcase}" do
            self.quality = 100
        end
        
        # thumbnail 70 x 70
        thumbnail70x70 = src.clone
        thumbnail70x70.scale! 70, 70
        thumbnail70x70.write "#{toDir + ds + imageName}-70x70.#{src.format.downcase}" do
            self.quality = 100
        end
        
        # thumbnail 99 x 99
        thumbnail99x99 = src.clone
        thumbnail99x99.scale! 99, 99
        thumbnail99x99.write "#{toDir + ds + imageName}-99x99.#{src.format.downcase}" do
            self.quality = 100
        end
        
        # big thumbnail
        thumbnailBig = src.clone
        thumbnailBig.composite! wm, 0, 0, Magick::OverCompositeOp
        thumbnailBig.crop! 0, 0, 562, 374
        thumbnailBig.write "#{toDir + ds + imageName}-562x374.#{src.format.downcase}" do
            self.quality = 100
        end
        
        # medium thumbnail
        thumbnailMedium = thumbnailBig.clone
        thumbnailMedium.scale! 249, 166
        thumbnailMedium.write "#{toDir + ds + imageName}-249x166.#{src.format.downcase}" do
            self.quality = 100
        end

        # result
        puts "!!! Image #{imageName} saved!"
    end
end
