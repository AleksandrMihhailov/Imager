require './Watermark'
require './MaterialsHunter'
require 'fileutils'

class ProcessMaterials
  def initialize db

    @hunter = MaterialsHunter.new db
    @wm = Watermark.new
    @origin_dir = ['..', 'storage', 'origin', 'materials'].join(File::Separator)

    dest_path = ['..', 'storage', 'public', 'materials'].join(File::Separator)
    origin_path = ['..', 'storage', 'origin', 'materials'].join(File::Separator)

    @hunter.get_result.each do |file|
      FileUtils.cp file[:file][:file], [origin_path, "#{file[:file][:name]}.#{file[:file][:extension]}"].join(File::Separator)
      @wm.add_watermark_to_material dest_path, file
    end
  end
end
