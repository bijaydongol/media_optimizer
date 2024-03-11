require_relative "version"

module MediaOptimizer
  require 'mini_magick'
  class Image
    VALID_CONTENT_TYPE = %w[png img jpg bmp tiff svg webp raw eps psd].freeze
    GRADUAL_IMAGE_QUALITY_DECREMENT = 5
    KILOBYTE = 1024

    def resize(image, height, width = height)
      resized_image = process_image(image).resize_to_limit(height, width).call
      create_blob(resized_image)
    end

    def convert_type(image, type)
      converted_image = if File.extname(image) == image.content_type
                          image
                        else
                          return "Invalid file type to convert." unless VALID_CONTENT_TYPE.include?(type)

                          process_image(image).convert(type).call
                        end
      create_blob(converted_image)
    end

    def compress_image(image, quality)
      return image if quality_out_of_bound

      image_quality = quality
      image = process_image(image).quality(image_quality).call
      create_blob(image)
    end

    def dimension(image)
      file = file_dimension(image)
      [file.height, file.width]
    end

    def size(image, unit = 'MB')
      bytes = file_size(image)
      case unit.upcase
      when "KB"
        bytes /= KILOBYTE
      when "MB"
        bytes /= (KILOBYTE * KILOBYTE)
      when "GB"
        bytes /= (KILOBYTE * KILOBYTE * KILOBYTE)
      end
      bytes.to_s + " " + unit.upacse
    end

    private

    def create_blob(image)
      ActiveStorage::Blob.create_and_upload!(io: image, filename: File.basename(image), content_type: image.content_type)
    end

    def file_size(file)
      File.size(file)
    end

    def process_image(image)
      ImageProcessing::MiniMagick.source(image)
    end

    def file_dimension(image)
      MiniMagick::Image.open(image.to_io)
    end

    def quality_out_of_bound
      quality >= 100 || quality <= 0
    end
  end
end