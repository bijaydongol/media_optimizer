require_relative "../../lib/media_optimizer/image"

RSpec.describe MediaOptimizer do
  let(:image) { 'woman.jpg' }

  describe "#resize" do
    it "resizes the image to the specified dimensions" do
      image_object = MediaOptimizer::Image.new
      resized_image = image_object.resize(image, 100, 100)
      expect(resized_image.height).to eq(100)
      expect(resized_image.width).to eq(100)
    end
  end

  describe "#convert_type" do
    it "converts the image to the specified type" do
      image_object = MediaOptimizer::Image.new
      file_type = %w[png img jpg bmp tiff svg webp raw eps psd].sample
      converted_image = image_object.convert_type(image, file_type)
      expect(File.extname(converted_image)).to eq(file_type)
    end
  end

  describe "#compress_image" do
    it "compresses the image with the specified quality" do
      image_object = MediaOptimizer::Image.new
      compressed_image = image_object.compress_image(image, 80)
      expect(File.size(compressed_image)).to be < File.size(image)
    end
  end

  describe "#dimension" do
    it "returns the dimensions of the image" do
      image_object = MediaOptimizer::Image.new
      height, width = image_object.dimension(image)
      original_file_dimension = image_object.send(:file_dimension, image_object)
      expect(height).to eq(original_file_dimension.height)
      expect(width).to eq(original_file_dimension.width)
    end
  end

  describe "#size" do
    it "returns the size of the image in the specified unit" do
      image_object = MediaOptimizer::Image.new
      size_in_mb = image_object.size(image, 'MB')
      expect(size_in_mb).to eq(image_object.send(:file_size, image))
    end
  end
end