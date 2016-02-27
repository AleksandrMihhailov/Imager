
##
# File hunter for materials with image size check
##

require 'fileutils'

class MaterialsHunter

  def initialize db
    @db = db
    @paths = {
      :img     => ['..', 'storage', 'img'].join(File::Separator),
      :gallery => ['..', 'storage', 'gallery'].join(File::Separator),
      :fabrics => ['..', 'storage', 'fabrics'].join(File::Separator),
      :images  => ['..', 'storage', 'fabrics', 'images'].join(File::Separator)
    }
    @result = Array.new
    @result_count = 0
    @bad_result = Array.new
    #run
    #get_files @paths[:img]
    #count_directories @paths
    ### puts db_materials
    #puts "Materials count: #{get_materials.count}"
    
    material_files = Hash.new
    files_count = 0
    get_all_files(@paths).each do |file|
      material_files[file[:name]] = file
      #puts file
      files_count += 1
    end
    puts "Materials files count: #{files_count}"

    #db_materials = Hash.new
    db_materials_count = 0
    get_materials.each do |item|
      #puts "#{item['gallery_id']} => #{item['file']} => #{item['ext']}"
      #db_materials[item['file']] = item
      #db_materials_count += 1
      #
      # Final cut
      db_materials_count += 1
      if material_files.include? item['file']
        @result_count += 1
        @result.push({
          :file => material_files[item['file']],
          :db   => item
        })
      else
        @bad_result.push item
      end
    end
    puts "DB Materials count: #{db_materials_count}"
    puts "Result count: #{@result_count}"

  end

  def get_result
    @result
  end

  def get_bad_result
    @bad_result
  end

  def get_materials
    @db.query "SELECT *
      FROM fabrics_gallery
      LEFT JOIN fabrics
      ON fabrics_gallery.fabric_id = fabrics.id
      LEFT JOIN gallery
      ON gallery.id = fabrics_gallery.gallery_id"
  end

  def get_files path
    path = [path, '*'].join(File::Separator)
    count = 0
    Dir.glob(path).each do |f|
      puts f.split(File::Separator).last
      count += 1
    end
    puts "Count: #{count}"
  end

  def get_all_files paths
    data = Array.new
    paths.each do |key, path|
      files = [path, '*'].join(File::Separator)
      Dir.glob(files).each do |file|
        file_data = file.split File::Separator
        #puts file_data
        data.push({
          :name      => file_data.last.split('.').first,
          :extension => file_data.last.split('.').last,
          :file      => file,
          :path      => path,
          :path_key  => key
        })
      end
    end
    data
  end

  def count_directories paths
    paths.each do |key, path|
      files = [path, '*'].join(File::Separator)
      files = Dir.glob(files).count
      puts "#{key} => #{files}"
    end
  end

  def run
    puts get_materials.count
  end
end
