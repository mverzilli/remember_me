module ApplicationHelper
  def link_to_remove_fields(name, f, options={})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this); notifySubscribersConfirm()", options)

  end
  
  def link_to_edit_fields(name, f, association, edit_object, options={})
    fields = edit_fields_for f, association, edit_object, options
    
    link_to_function(name, "edit_fields(this, \"#{escape_javascript(fields)}\")")
  end

  def button_to_edit_fields( f, association, edit_object, options={})
    fields = edit_fields_for f, association, edit_object, options
    button_to_function("", "edit_fields(this, \"#{escape_javascript(fields)}\")", :class => "icon farrow")
  end
  
  def edit_fields_for(f, association, edit_object, options={})
    f.fields_for(association, edit_object, :child_index => edit_object, :index => options[:index]) do |builder|
      render(association.to_s.singularize + "_controls", :f => builder)
    end
  end

  def link_to_add_fields(name, f, association, options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_add", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", options)
  end
end

def styled_button_to(name, *args, &block)
  html_options = args.extract_options!.symbolize_keys

  function = block_given? ? update_page(&block) : args[0] || ''
  onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"

  content_tag(:button, name, html_options.merge(:type => 'button', :class => "white", :onclick => onclick)) do
    (content_tag :span) + name
  end
end

def styled_submit(name, *args)
  content_tag(:button, :type => 'submit', :class => "white") do
    (content_tag :span)+ name
  end
end
