require './Watermark'
require './MaterialsHunter'
require 'fileutils'

class ProcessMaterials
  def initialize db

    @hunter = MaterialsHunter.new db
    @wm = Watermark.new
    @origin_dir = ['..', 'storage', 'origin', 'materials'].join File::Separator

    bad_ids = Array.new
    @hunter.get_result.each do |file|
      image = Magick::Image.read(file[:file][:file]).first
      #puts "#{file[:file][:file]} => #{image.columns}x#{image.rows}"
      unless (image.columns.to_i == 600 && image.rows.to_i == 600) or (image.columns.to_i == 5184 && image.rows.to_i == 3456)
        puts "#{file[:db]['code']} => #{file[:db]['id']} => #{image.columns}x#{image.rows}"
        bad_ids.push file[:db]['id']
      end
      image.destroy!
    end
    puts "Count: #{bad_ids.count}"

  end
end
