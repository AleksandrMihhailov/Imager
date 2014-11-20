#!/usr/bin/env ruby

require 'RMagick'
require 'Mysql2'
require 'yaml'

# defining directory separator
DS = File::Separator

# variables
realPath = ['..', 'application', 'storage', 'img'].join DS
destPath = ['..', 'admin.motiva.ee', 'content', 'img'].join DS

# loading config
config = ['..', 'application', 'app', 'config.admin.yml']
config = YAML.load_file config.join DS

# connecting to Mysql2
db = Mysql2::Client.new(
    :host     => config['database']['hostname'],
    :username => config['database']['username'],
    :password => config['database']['password'],
    :database => config['database']['database']
)

waterMark = ['..', 'application', 'watermarks', 'blindex_watermark-600x600.png'].join DS
waterMark = Magick::Image.read(waterMark).first

fabrics = db.query 'SELECT * FROM gallery WHERE type = \'fabric\''
fabricsCount = 0
puts 'Fabrics: ' + fabrics.count.to_s
fabrics.each do |_file_|

    file = realPath + DS + _file_['file']

    if File.exist? file + '.jpg' then
        src = Magick::Image.read(file + '.jpg').first
    end

    if File.exist? file + '.png' then
        src = Magick::Image.read(file + '.png').first
    end

    if File.exist? file + '.jpeg' then
        src = Magick::Image.read(file + '.jpeg').first
    end

    if src.columns.to_i <= 600 && src.rows.to_i <= 600 then

        # 60x60 scan
        img = src.clone
        img.scale! 60, 60
        img.write destPath + DS + _file_['file'] + '-60x60.' + _file_['ext'] do
            self.quality = 100
        end
        img.destroy!

        # 70x70 scan
        img = src.clone
        img.scale! 70, 70
        img.write destPath + DS + _file_['file'] + '-70x70.' + _file_['ext'] do
            self.quality = 100
        end
        img.destroy!

        # 99x99 scan
        img = src.clone
        img.scale! 99, 99
        img.write destPath + DS + _file_['file'] + '-99x99.' + _file_['ext'] do
            self.quality = 100
        end
        img.destroy!

        # 562x374 scan with watermark
        src.composite! waterMark, 0, 0, Magick::OverCompositeOp
        src.crop! 0, 0, 562, 374
        src.write destPath + DS + _file_['file'] + '-562x374.' + _file_['ext'] do
            self.quality = 100
        end

        # 249x166 scan with watermark
        src.scale! 249, 166
        src.write destPath + DS + _file_['file'] + '-249x166.' + _file_['ext'] do
            self.quality = 100
        end

        fabricsCount += 1

    end

    if src.columns.to_i == 5184 && src.rows.to_i == 3456 then
    
        # resizin origin image
        img = src.clone.scale! 600, 400

        # creating blank image
        blankImg = Magick::Image.new 600, 600 do
            self.background_color = 'none'
            self.format = 'PNG'
        end
        blankImg.composite! img, 0, 100, Magick::OverCompositeOp

        # 60x60 photo
        thumb = blankImg.clone.scale! 60, 60
        thumb.write destPath + DS + _file_['file'] + '-60x60.' + _file_['ext'] do
            self.quality = 100
        end
        thumb.destroy!
        
        # 70x70 photo
        thumb = blankImg.clone.scale! 70, 70
        thumb.write destPath + DS + _file_['file'] + '-70x70.' + _file_['ext'] do
            self.quality = 100
        end
        thumb.destroy!
        
        # 99x99 photo
        thumb = blankImg.clone.scale! 99, 99
        thumb.write destPath + DS + _file_['file'] + '-99x99.' + _file_['ext'] do
            self.quality = 100
        end
        thumb.destroy!

        # 562x374 photo with watermark
        img.scale! 562, 374
        img.composite! waterMark, 0, 0, Magick::OverCompositeOp
        img.write destPath + DS + _file_['file'] + '-562x374.' + _file_['ext'] do
            self.quality = 100
        end

        # 249x166 photo with watermark
        img.scale! 249, 166
        img.write destPath + DS + _file_['file'] + '-249x166.' + _file_['ext'] do
            self.quality = 100
        end

        blankImg.destroy!
        img.destroy!

        fabricsCount += 1

    end

    print '.'
    src.destroy!
    
end

puts 'Fabrics: ' + fabricsCount.to_s
