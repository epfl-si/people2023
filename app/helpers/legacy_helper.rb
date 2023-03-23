module LegacyHelper
  def position_with_class_delegate(affiliation)
    [
      affiliation.t_position(I18n.locale),
      affiliation.class_delegate.nil? ? nil : t("class_delegate"), 
      "<span class='font-weight-normal'>#{affiliation.unit.label(I18n.locale)}</span>"
    ].compact.join(", ").html_safe
  end

  def address(a)
    a.lines[1..].join("<br>").html_safe
  end

  def hierarchy_links(y)
    y.split(" ").map do |l|
      link_to(l, "https://search.epfl.ch/?filter=unit&acro=#{l}")
    end.join(" > ").html_safe
  end


end
