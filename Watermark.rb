class Watermark

  @@wm_path = ['..', 'application', 'watermarks'].join DS
  @@wm = {
    :wm_blindex_60x60_v1_1     => [@@wm_path, 'wm_blindex_60x60_v1-1.png'].join(DS),
    :wm_blindex_70x70_v1_1     => [@@wm_path, 'wm_blindex_70x70_v1-1.png'].join(DS),
    :wm_blindex_99x99_v1_1     => [@@wm_path, 'wm_blindex_99x99_v1-1.png'].join(DS),
    :wm_blindex_166x249_v1_1   => [@@wm_path, 'wm_blindex_166x249_v1-1.png'].join(DS),
    :wm_blindex_249x166_v1_1   => [@@wm_path, 'wm_blindex_249x166_v1-1.png'].join(DS),
    :wm_blindex_249x166_v2_1   => [@@wm_path, 'wm_blindex_249x166_v2-1.png'].join(DS),
    :wm_blindex_374x562_v1_1   => [@@wm_path, 'wm_blindex_374x562_v1-1.png'].join(DS),
    :wm_blindex_562x374_v1_1   => [@@wm_path, 'wm_blindex_562x374_v1-1.png'].join(DS),
    :wm_blindex_562x374_v2_1   => [@@wm_path, 'wm_blindex_562x374_v2-1.png'].join(DS),
    :wm_blindex_600x600_v1_1   => [@@wm_path, 'wm_blindex_600x600_v1-1.png'].join(DS),
    :wm_blindex_600x600_v2_1   => [@@wm_path, 'wm_blindex_600x600_v2-1.png'].join(DS),
    :wm_blindex_600x800_v1_1   => [@@wm_path, 'wm_blindex_600x800_v1-1.png'].join(DS),
    :wm_blindex_800x600_v1_1   => [@@wm_path, 'wm_blindex_800x600_v1-1.png'].join(DS),
    :wm_blindex_600x900_v1_1   => [@@wm_path, 'wm_blindex_600x900_v1-1.png'].join(DS),
    :wm_blindex_900x600_v1_1   => [@@wm_path, 'wm_blindex_900x600_v1-1.png'].join(DS),
    :wm_blindex_1280x1920_v1_1 => [@@wm_path, 'wm_blindex_1280x1920_v1-1.png'].join(DS),
    :wm_blindex_1920x1280_v1_1 => [@@wm_path, 'wm_blindex_1920x1280_v1-1.png'].join(DS),
    :wm_blindex_1280x1920_v2_1 => [@@wm_path, 'wm_blindex_1280x1920_v2-1.png'].join(DS),
    :wm_blindex_1920x1280_v2_1 => [@@wm_path, 'wm_blindex_1920x1280_v2-1.png'].join(DS),
    :wm_blindex_3456x5184_v1_1 => [@@wm_path, 'wm_blindex_3456x5184_v1-1.png'].join(DS),
    :wm_blindex_5184x3456_v1_1 => [@@wm_path, 'wm_blindex_5184x3456_v1-1.png'].join(DS)
  }

  def initialize
    self.check_watermarks
  end

  def add_watermark file_path, file_hash, dest_path
    
    file = [file_path, file_hash[:origin]].join File::Separator

    if File.exist? file

      image = Magick::Image.read(file).first

      # working with product
      if image.columns.to_i == 1280 && image.rows.to_i == 1920
        
        watermark = Magick::Image.read(@@wm[:wm_blindex_1280x1920_v2_1]).first

        # blank image
        blank = Magick::Image.new 1920, 1920 do
          self.background_color = 'none'
          self.format = 'PNG'
        end

        blank.composite! image, 320, 0, Magick::OverCompositeOp

        # scaling and saving thumbnail 99x99
        thumb = blank.clone.scale! 99, 99
        thumb.write [dest_path, "#{file_hash[:filename]}-99x99.#{file_hash[:extension]}"].join File::Separator do
          self.quality = 100
        end
        thumb.destroy!

        # scaling and saving thumbnail 70x70
        thumb = blank.clone.scale! 70, 70
        thumb.write [dest_path, "#{file_hash[:filename]}-70x70.#{file_hash[:extension]}"].join File::Separator do
          self.quality = 100
        end
        thumb.destroy!

        # scaling and saving thumbnail 60x60
        thumb = blank.clone.scale! 60, 60
        thumb.write [dest_path, "#{file_hash[:filename]}-60x60.#{file_hash[:extension]}"].join File::Separator do
          self.quality = 100
        end
        thumb.destroy!

        # adding watermark to image
        image.composite! watermark, 0, 0, Magick::OverCompositeOp

        # saving image with original size
        image.write [dest_path, "#{file_hash[:filename]}-1280x1920.#{file_hash[:extension]}"].join File::Separator do
          self.quality = 100
        end

        # scaling and saving image with zoom size
        img = image.clone.scale! 600, 900
        img.write [dest_path, "#{file_hash[:filename]}-preview.#{file_hash[:extension]}"].join File::Separator do
          self.quality = 100
        end
        img.destroy!

        # scaling and saving image with product item size
        img = image.clone.scale! 374, 562
        img.write [dest_path, "#{file_hash[:filename]}-374x562.#{file_hash[:extension]}"].join File::Separator do
          self.quality = 100
        end
        img.destroy!

        img = image.clone.scale! 166, 249
        img.write [dest_path, "#{file_hash[:filename]}-166x249.#{file_hash[:extension]}"].join File::Separator do
          self.quality = 100
        end
        img.destroy!

        # destroing main image object
        image.destroy!

        # destroing blank image
        blank.destroy!

        puts "#{file_hash[:origin]} pocessed!"

      end
    else
      puts "File #{file} not exists! Sorry!"
    end
  end

  def add_watermark_to_material dest_path, file_data
    if File.exist? file_data[:file][:file]

      image = Magick::Image.read(file_data[:file][:file]).first

      if image.columns.to_i == 5184 and image.rows.to_i == 3456

        image.scale! 1920, 1280
        watermark = Magick::Image.read(@@wm[:wm_blindex_1920x1280_v2_1]).first

        blank = Magick::Image.new 1920, 1920 do
          self.background_color = 'none'
          self.format = 'PNG'
        end

        blank.composite! image, 0, 320, Magick::OverCompositeOp

        # scaling to 99x99
        thumb = blank.clone.scale! 99, 99
        thumb.write [dest_path, "#{file_data[:db]['file']}-99x99.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        thumb.destroy!

        # scaling to 70x70
        thumb = blank.clone.scale! 70, 70
        thumb.write [dest_path, "#{file_data[:db]['file']}-70x70.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        thumb.destroy!

        # scale to 60x60
        thumb = blank.clone.scale! 60, 60
        thumb.write [dest_path, "#{file_data[:db]['file']}-60x60.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        thumb.destroy!

        # making watermar on image
        image.composite! watermark, 0, 0, Magick::OverCompositeOp

        # zoom image
        img = image.clone.scale! 900, 600
        img.write [dest_path, "#{file_data[:db]['file']}-preview.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        img.destroy!

        # normal material size scaling
        img = image.clone.scale! 562, 374
        img.write [dest_path, "#{file_data[:db]['file']}-562x374.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        img.destroy!

        # and more another image with watermark
        img = image.clone.scale! 249, 166
        img.write [dest_path, "#{file_data[:db]['file']}-249x166.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        img.destroy!

        # distroying blank image
        blank.destroy!

        puts "#{file_data[:file][:file]} processed!"

      elsif image.columns.to_i == 600 or image.rows.to_i == 600

        # getting watermark
        watermark = Magick::Image.read(@@wm[:wm_blindex_600x600_v2_1]).first

        # generating blank image
        blank = Magick::Image.new 600, 600 do
          self.background_color = 'none'
          self.format = 'PNG'
        end

        # processing 600 and 600
        if image.columns.to_i == 600 and image.rows.to_i == 600
          blank.composite! image, 0, 0, Magick::OverCompositeOp
          img = image.clone.crop! 0, 0, 600, 400
          puts "#{file_data[:file][:file]} processed!"
        end

        # processing 600 and <600
        if image.columns.to_i == 600 and image.rows.to_i < 600

          image_shift = (600 - image.rows.to_i) / 2
          blank.composite! image, 0, image_shift, Magick::OverCompositeOp

          if image.rows.to_i > 400
            img = image.clone.crop! 0, 0, 600, 400
          else
            img = Magick::Image.new 600, 400 do
              self.background_color = 'none'
              self.format = 'PNG'
            end
            v_shift = (400 - image.rows.to_i) / 2
            img.composite! image, 0, v_shift, Magick::OverCompositeOp
          end
        end

        # processing <600 and 600
        if image.columns.to_i < 600 and image.rows.to_i == 600

          image_shift = (600 - image.columns.to_i) / 2
          blank.composite! image, image_shift, 0, Magick::OverCompositeOp

          img = Magick::Image.new 600, 600 do
            self.background_color = 'none'
            self.format = 'PNG'
          end
          h_shift = (600 - image.columns.to_i) / 2
          img.composite! image, h_shift, 0, Magick::OverCompositeOp

          img.crop! 0, 0, 600, 400
        end

        # Processing 562x374
        wm = Magick::Image.read(@@wm[:wm_blindex_562x374_v2_1]).first
        thumb = img.clone.scale! 562, 374
        thumb.composite! wm, 0, 0, Magick::OverCompositeOp
        thumb.write [dest_path, "#{file_data[:db]['file']}-562x374.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        wm.destroy!
        thumb.destroy!

        # Processing 249x166
        wm = Magick::Image.read(@@wm[:wm_blindex_249x166_v2_1]).first
        thumb = img.clone.scale! 249, 166
        thumb.composite! wm, 0, 0, Magick::OverCompositeOp
        thumb.write [dest_path, "#{file_data[:db]['file']}-249x166.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        wm.destroy!
        thumb.destroy!

        # destroying croped image
        img.destroy!

        # creating preview image
        thumb = blank.clone.composite! watermark, 0, 0, Magick::OverCompositeOp
        thumb.write [dest_path, "#{file_data[:db]['file']}-preview.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        thumb.destroy!

        # creating 99x99
        thumb = blank.clone.scale! 99, 99
        thumb.write [dest_path, "#{file_data[:db]['file']}-99x99.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        thumb.destroy!

        # creating 70x70
        thumb = blank.clone.scale! 70, 70
        thumb.write [dest_path, "#{file_data[:db]['file']}-70x70.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        thumb.destroy!

        # creating 60x60
        thumb = blank.clone.scale! 60, 60
        thumb.write [dest_path, "#{file_data[:db]['file']}-60x60.#{file_data[:db]['ext']}"].join(File::Separator) do
          self.quality = 100
        end
        thumb.destroy!

        watermark.destroy!
        blank.destroy!

        puts "#{file_data[:file][:file]} processed!"

      else
        puts "#{file_data[:file][:file]} #{image.columns}x#{image.rows} not processed!"
      end

      image.destroy!
    else
      puts "File #{file_data[:file][:file]} not found! Sry!"
    end
  end

  def check_watermarks
    puts "\n======= Checking watermark files =======\n"
    exist = 0
    notExist = 0
    @@wm.each do |key, wm|
      if File.exist? wm
        puts "#{key} Okay"
        exist += 1
      else
        puts "#{key} Not Okay"
        notExist += 1
      end
    end
    puts "\n======= Watermarks exist: #{exist}, not exist: #{notExist}, total checked: #{exist + notExist} =======\n\n"
  end
end
