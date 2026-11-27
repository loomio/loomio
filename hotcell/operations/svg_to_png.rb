# frozen_string_literal: true

require "active_storage/hot_cell/server/vips_operation"

class SvgToPngOperation < ActiveStorage::HotCell::Server::VipsOperation
  operation "loomio.svg_to_png"

  limits deadline: 10, memory: 1024 * 1024**2, file_size: 4 * 1024**2, open_files: 64

  def perform(inputs, outputs)
    svg = inputs.first.io.read
    # image_processing 2.2 blocks untrusted libvips loaders globally; unblock
    # only inside this disposable single-request Hot Cell worker.
    ::Vips.vips_block_untrusted_set(0) if ::Vips.respond_to?(:vips_block_untrusted_set)
    png = ::Vips::Image.svgload_buffer(svg).write_to_buffer(".png")
    outputs.first.io.write(png)
    {}
  end
end
