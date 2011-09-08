module InsteddAppHelper
  def flash_message
    if flash[:notice]
      content_tag :div, :class => 'flash_notice' do
        flash[:notice]
      end
    end

    if flash[:error]
      content_tag :div, :class => 'flash_error' do
        flash[:error]
      end
    end
    
    if flash[:alert]
      content_tag :div, :class => 'flash_error' do
        flash[:alert]
      end
    end
  end
end

module DeviseHelper  
  def devise_error_messages!
    return if resource.errors.full_messages.empty?
    
    (content_tag :div, :class => 'centered box w30 error_description' do
      (content_tag :h2, 'The following errors occurred') \
      + \
      (content_tag :ul do
        raw resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      end)
    end)
  end
end