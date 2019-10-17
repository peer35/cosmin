module RecordsHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:filter=>status_filter,:sort => column, :direction => direction, :letter => params[:letter]}, {:class => css_class}
  end
end
