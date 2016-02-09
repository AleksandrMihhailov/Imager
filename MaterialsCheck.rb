require 'fileutils'
require './Watermark'

class Array
  def except *values
    self - values
  end
end

class MaterialsCheck

  def initialize db
    
    @db  = db
    @log = true

    @fromDir   = ['..', 'storage', 'fabrics'].join DS
    @originDir = ['..', 'storage', 'origin', 'materials'].join DS
    @destDir   = ['..', 'storage', 'public', 'materials'].join DS

    #wm = Watermark.new

    #data = self.get_files

    materials = Array.new

    get_main_materials.each do |m|
      puts m['file'] if @log
      materials.push m['file']
    end

    puts "Materials count: #{get_main_materials.count}" if @log

    check_files materials

  end

  def get_main_materials
    @db.query 'SELECT * 
      FROM fabrics
      LEFT JOIN gallery
      ON fabrics.img = gallery.id'
  end

  def check_files file_names
    
    Dir.chdir @fromDir
    result = Array.new
    except = Array.new

    Dir.glob("*").each do |f|
      if file_names.include? f.split('.').first
        puts "#{f} - Okay" if @log
        result.push f
        #puts Dir.pwd
        #FileUtils.cp f, ['..', 'materials', f].join(File::Separator)
      else
        puts "#{f} - Fail" if @log
        except.push f
      end
    end

    puts "Good counter: #{result.count}" if @log
    puts "Bad counter: #{except.count}" if @log

  end
end
