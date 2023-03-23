module LegacyHelper
  def accred_function_with_class_delegate(accred)
    [
      accred.function, 
      accred.class_delegate.nil? ? nil : t("class_delegate"), 
      "<span class='font-weight-normal'>#{accred.unit.label(I18n.locale)}</span>"
    ].compact.join(",")   
  end
end
