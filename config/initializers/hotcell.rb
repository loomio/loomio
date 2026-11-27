# frozen_string_literal: true

module LoomioHotCell
  class UnprocessableUpload < StandardError; end
  class ConversionTemporarilyUnavailable < StandardError; end
end

HotCell.root  = ENV["HOTCELL_ROOT"]  # unset disables Hot Cell routing
HotCell.group = ENV["HOTCELL_GROUP"] # shared gid between app and cell

HotCell.register "active_storage",
  permanent: LoomioHotCell::UnprocessableUpload,
  transient: LoomioHotCell::ConversionTemporarilyUnavailable

if ENV["HOTCELL_ROOT"].present?
  Rails.application.config.after_initialize { HotCell.describe_cells }
end
