module ElementsHelper
  def ee_collapse(title, content_or_options_with_block = nil, options={}, &block)
    @ee_collapse_indx ||= 0
    @ee_collapse_indx = @ee_collapse_indx + 1
    indx = @ee_collapse_indx
    if block_given?
      content = capture(&block)
      options = content_or_options_with_block || {}
    else
      content = content_or_options_with_block
    end
    expanded = options.delete(:expanded)
    hopts = {
      class: expanded ? %w(collapse-title collapse-title-desktop) : %w(collapse-title collapse-title-desktop collapsed),
      data: {
        toggle: "collapse",
        target: "#collapse-#{indx}"
      },
      aria: {
        expanded: expanded ? "true" : "false",
        controls: "collapse-#{indx}"
      }
    }
    res = content_tag(:section, class: "collapse-container") do
      content_tag(:header, hopts) do 
        content_tag(:p, title, class: "title")
      end << content_tag(:div, content, class: %w(collapse collapse-item collapse-item-desktop), id: "collapse-#{indx}")
    end
  end
end
