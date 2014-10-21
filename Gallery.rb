class Gallery < Image

    @@fromDir = ['..', 'storage', 'gallery'].join DS
    @@filesDir = ['..', 'files', 'gallery'].join DS
    @@toDir = ['..', 'admin.motiva.ee', 'content', 'img'].join DS
    @@count = 0
    @@failCount = 0

    def initialize db
        
        # database
        @db = db

        # init watermark
        @wm = ['..', 'application', 'watermarks', 'blindex_watermark-600x600.png'].join DS
        unless File.exist? @wm
            puts "Watermark file not exists (#{@wm})!"
            exit
        end
        @wm = Magick::Image.read(@wm).first

        # run
        runGallery
    end

    def runGallery
        gallery = @db.query 'SELECT file FROM gallery WHERE file != \'\' AND type = \'fabric\''
        puts gallery.count
        gallery.each do |row|
            
            if File.exist?(@@fromDir + DS + row['file']) then
                
                # image name
                @imageName = row['file'].split('.').first.to_s

                # init fabric
                src = Magick::Image.read(@@fromDir + DS + row['file']).first

                if src.columns.to_i > 5000 && src.rows.to_i > 3000 then

                    # resize origin image
                    img = src.clone.scale! 600, 400

                    # creating blank image
                    newImg = Magick::Image.new 600, 600 do
                        self.background_color = 'none'
                        self.format = 'PNG'
                    end
                    newImg.composite! img, 0, 100, Magick::OverCompositeOp
                    
                    # creating thumbnail 60 x 60
                    img60 = newImg.clone.scale! 60, 60
                    img60.write @@toDir + DS + @imageName + '-60x60.png' do
                        self.quality = 100
                    end

                    # creating thumbnail 70 x 70
                    img70 = newImg.clone.scale! 70, 70
                    img70.write @@toDir + DS + @imageName + '-70x70.png' do
                        self.quality = 100
                    end

                    # creating thumbnail 99 x 99
                    img99 = newImg.clone.scale! 99, 99
                    img99.write @@toDir + DS + @imageName + '-99x99.png' do
                        self.quality = 100
                    end

                    # creating big image 562 x 374
                    img.scale! 562, 374
                    img.composite! @wm, 0, 0, Magick::OverCompositeOp
                    img.write @@toDir + DS + @imageName + '-562x374.png' do
                        self.quality = 100
                    end

                    # creating smaller image 249 x 166
                    img249 = img.scale! 249, 166
                    img249.write @@toDir + DS + @imageName + '-249x166.png' do
                        self.quality = 100
                    end

                    # destroing temparary image objects
                    img60.destroy!
                    img70.destroy!
                    img99.destroy!
                    img.destroy!
                    newImg.destroy!
                    img249.destroy!

                    # update image on database
                    file = @db.escape row['file']
                    imageName = @db.escape @imageName
                    @db.query "UPDATE gallery SET file = '#{imageName}', ext = 'png' WHERE file = '#{file}' LIMIT 1"

                    #infinite count
                    @@count += 1

                    # display log
                    puts "*#{row['file']} writed!"
                else 
                    @@failCount += 1
                    puts "-#{row['file']} failed!"
                end

                # destroy image
                src.destroy!
            end
        end

        puts "Failed #{@@failCount} images!"
        puts "Processed #{@@count} images!"
    end
end
