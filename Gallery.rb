class Gallery

    @@fromDir = ['..', 'storage', 'gallery'].join DS
    @@filesDir = ['..', 'files', 'gallery'].join DS
    @@toDir = ['..', 'admin.motiva.ee', 'content', 'img'].join DS
    @@count = 0

    def initsialize db
        @db = db
        getGallery
    end

    def getGallery
        gallery = @db.query('SELECT file FROM gallery WHERE file != \'\'')
        gallery.each do |row|
            
            if File.exist? @@fromDir + DS + row['file'] then
                
                # image name
                @imageName = row['file'].split('.')[0]

                # init fabric
                src = Magick::Image.read(@@fromDir + DS + row['file']).first

                # run
                thumbnail src, 60, 60
                thumbnail src, 70, 70
                thumbnail src, 99, 99
                thumbnail src, 562, 374
                thumbnail src, 249, 166

                # infinite count
                @@count += 1

                # display log
                puts "*#{row['file']} writed!"
            end
        end

        puts "Processed #{row['file']} images!"
    end
end
