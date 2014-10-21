class Fabrics < Image

    @@fromDir  = ['..', 'storage', 'fabrics'].join DS
    @@toDir    = ['..', 'admin.motiva.ee', 'content', 'img'].join DS
    @@count    = 0

    def initialize db

        # database
        @db = db
        
        # init wotermark
        @wm = ['..', 'application', 'watermarks', 'blindex_watermark-600x600.png'].join DS
        unless File.exist? @wm
            puts "WaterMark file not exists (#{@wm})!"
            exit
        end
        @wm = Magick::Image.read(@wm).first

        # run
        runFabrics
    end

    def runFabrics
        fabrics = @db.query 'SELECT id, image FROM fabrics  WHERE image != \'\''
        puts fabrics.count
        fabrics.each do |fabric|
            
            if File.exist? @@fromDir + DS + fabric['image'] then

                # image name
                @imageName = fabric['image'].split('.')[0].to_s

                # init fabric
                src = Magick::Image.read(@@fromDir + DS + fabric['image']).first

                # run
                thumbnail src, 60, 60, @@toDir, @imageName
                thumbnail src, 70, 70, @@toDir, @imageName
                thumbnail src, 99, 99, @@toDir, @imageName
                image src, 562, 374, @@toDir, @imageName
                thumbnail src, 249, 166, @@toDir, @imageName

                # insert fabric to gallery
                imageName = @db.escape @imageName
                imageExt = src.format.downcase
                @db.query "INSERT INTO gallery (file, ext, type) VALUES('#{imageName}', '#{imageExt}', 'fabric')"
                @db.query "INSERT INTO fabrics_gallery (fabric_id, gallery_id) VALUES (#{fabric['id']}, #{@db.last_id})"

                # infinite count
                @@count += 1

                # display log
                puts "*#{fabric['image']} writed!"
            end
        end
        puts "Processed #{@@count} fabrics."
    end
end
