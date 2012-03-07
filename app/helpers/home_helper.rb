module HomeHelper
  def motion_panel_class(index)
    'last' if row_end_index?(index)
  end

  private

    def row_end_index?(index, row_length = 4)
      index % row_length == 0 && index != 0
    end
end
