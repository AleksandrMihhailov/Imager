#! /usr/bin/env ruby

require 'RMagick'
require 'Mysql2'

options = {
    :crop => false
}

# check RMagick gem
if defined?(RMagick)
    puts 'RMagick not installed!'
    exit
else
    puts 'RMagick OK!'
end

# check mysql extension
if defined? Mysql
    puts 'Mysql not installed'
    exit
else
    puts 'Mysql OK!'
end

# connecting to mysql
db = Mysql2::Client.new(
    :host => 'd26107.mysql.zone.ee',
    :username => 'd26107sa61910',
    :password => 'QWEasd123',
    :database => 'd26107sd59363',
    :encoding => 'utf8'
)

ds = File::Separator
fromDir = ".#{ds}motiva#{ds}application#{ds}storage#{ds}fabrics#{ds}images"
toDir = ".#{ds}motiva#{ds}content#{ds}img"
wmFile = ".#{ds}motiva#{ds}application#{ds}watermarks#{ds}motiva600x600.png"

# watermark
wm = Magick::Image.read(wmFile).first

fabrics = db.query('select * from fabrics')
fabrics.each do |fabric|
    unless Dir.exist? fromDir + ds + fabric['image']

        puts fabric['image'] + ' ready!'

        #get image name
        imageName = fabric['image'].split('.')[0]

        # init file
        src = Magick::Image.read(fromDir + ds + fabric['image']).first

        # sae origin image
        src.write ".#{ds}motiva#{ds}application#{ds}files#{ds}fabrics#{ds + imageName}"
        
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

=begin
# start cropping fabrics
Dir.foreach(fromDir) do |fabric|

    if fabric != '.' && fabric != '..' && options[:crop]

        #get image name
        imageName = fabric.split('.')[0]

        # init file
        src = Magick::Image.read(fromDir + ds + fabric).first
        
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
        puts "!!! Image #{fabric} ready!"
    end
end
=end
