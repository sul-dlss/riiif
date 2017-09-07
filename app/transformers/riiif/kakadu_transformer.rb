module Riiif
  # Transforms an image using Kakadu
  class KakaduTransformer < AbstractTransformer
    def command_factory
      KakaduCommandFactory
    end

    def transform
      with_tempfile do |file_name|
        execute(command_builder.command(file_name))
        post_process(file_name, command_builder.reduction_factor)
      end
    end

    def with_tempfile
      Tempfile.open(['riiif-intermediate', '.bmp']) do |f|
        yield f.path
      end
    end

    # The data we get back from kdu_expand is a bmp and we need to change it
    # to the requested format by calling Imagemagick.
    def post_process(intermediate_file, reduction_factor)
      # Calculate a new set of transforms with respect to reduction_factor
      transformation = if reduction_factor
                         self.transformation.without_crop(image_info).reduce(reduction_factor)
                       else
                         self.transformation.without_crop(image_info)
                       end
      Riiif::File.new(intermediate_file).extract(transformation, image_info)
    end

    private

      def tmp_path
        @link_path ||= LinkNameService.create
      end
  end
end
