
  #
  # Origin file ~ 1280x1920
  #

require 'fileutils'
require './Watermark'

class ProductsCheck

  def initialize db

    @db = db
    @log = false

    @fromDir = ['..', 'storage', 'img'].join DS
    @originDir = ['..', 'storage', 'origin', 'products'].join DS
    @destDir = ['..', 'storage', 'public', 'products'].join DS

    wm = Watermark.new

    filesData = self.get_files

    filesData.each do |file|
      self.copy_file [@fromDir, file[:origin]].join(DS), [@originDir, file[:origin]].join(DS)
      wm.add_watermark @fromDir, file, @destDir
    end
  end

  def copy_file file, dest
    FileUtils.cp file, dest
  end

  def get_products
    products = @db.query "SELECT
        products.id,
        products_values.title,
        gallery.file,
        gallery.ext as extension
      FROM products
      LEFT JOIN products_values
      ON products.id = products_values.id
      AND products_values.lang_id = 1
      LEFT JOIN gallery
      ON products.image = gallery.id
      WHERE products.category_id != 0"
    
    products.each do |p|
      puts "#{p['id']} :: #{p['title']} :: #{p['file']}.#{p['extension']}" if @log
    end
    
    puts "Products count: #{products.count}" if @log
  end

  def get_product_by_filename fileName

    @db.query "SELECT
        products.id,
        products_values.title,
        gallery.file,
        gallery.ext AS extension
      FROM products
      LEFT JOIN products_values
      ON products.id = products_values.id
      AND products_values.lang_id = 1
      LEFT JOIN gallery
      ON gallery.id = products.image
      WHERE products.category_id != 0
      AND gallery.file = '#{fileName}'
      LIMIT 1"

    # @db.query "SELECT 
    #     products.id,
    #     gallery.file,
    #     gallery.ext AS extension
    #   FROM gallery
    #   LEFT JOIN products_gallery
    #   ON gallery.id = products_gallery.gallery_id
    #   LEFT JOIN products
    #   ON products.id = products_gallery.product_id
    #   WHERE gallery.file = '#{fileName}'
    #   LIMIT 1"

  end

  def get_files

    Dir.chdir @fromDir

    counter = 0

    result = []

    Dir.glob("*").each do |f|
      
      file = f.split '.'
      dbFile = self.get_product_by_filename(file[0])

      if dbFile.count === 1
        
        puts "#{dbFile.first} :: #{f} :: #{(File.size(f).to_f / 2**20).round(2)} mb" if @log

        tmpData = {
          :origin => f,
          :filename => dbFile.first['file'],
          :extension => dbFile.first['extension']
        }

        result.push tmpData
        counter += 1
      end
    end

    Dir.chdir '../../Imager'
    
    puts "Files found: #{counter}" if @log

    result
  end
end
