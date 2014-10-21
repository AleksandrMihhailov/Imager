class Products

    @@fromDir = ['..', 'application', 'storage', 'products'].join DS
    @@toDir = ['..', 'admin.motiva.ee', 'content', 'img'].join DS
    @@count = 0
    @@failCount = 0

    def initialize db
        @db = db

        # init watermark
        @wm = ['..', 'application', 'watermarks', 'blindex_watermark-600x600.png'].join DS
        unless File.exists? @wm
            puts "Watermark file not exists (#{@wm})!"
            exit
        end
        @wm = Magick::Image.read(@wm).first

        #run
        runProducts
    end

    def runProducts

        products = @db.query 'SELECT file, ext FROM gallery WHERE type = \'product\''
        puts products.count

        products.each do |row|

            file = @@fromDir + DS + row['file'] + '.' + row['ext']
            if File.exist?(file) then

                src = Magick::Image.read(file).first

                if src.columns.to_i == 3456 && src.rows.to_i == 5184 then

                    puts row['file'] + '.' + row['ext'] + ' are Okay!'
                    @@count += 1
                else
                    @@failCount += 1
                end

                src.destroy!
            end
        end

        puts 'Good files: ' + @@count.to_s
        puts 'Bad files: ' + @@failCount.to_s
    end
end