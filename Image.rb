class Image

    def thumbnail src, width, height, toDir, imageName
        img = src.clone
        img.scale! width, height

        dest = toDir.to_s + DS + imageName 
        dest += '-'+width.to_s+'x'+height.to_s
        dest += '.'+src.format.downcase

        img.write dest do
            self.quality = 100
        end
    end

    def image src, width, height, toDir, imageName
        src.composite! @wm, 0, 0, Magick::OverCompositeOp
        src.crop! 0, 0, width, height

        dest = toDir.to_s + DS + imageName 
        dest += '-'+width.to_s+'x'+height.to_s
        dest += '.'+src.format.downcase
        
        src.write dest do
            self.quality = 100
        end
    end
end
