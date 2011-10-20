module MailerHelper
  
  def body
    content_tag :div, :style => style_for(body_style) do
      yield
    end
  end
  
  def content
    content_tag :div, :style => style_for(content_style) do
      yield
    end
  end
  
  def header
    content_tag :div, :style => style_for(header_style) do
      yield
    end
  end
  
  def footer
    content_tag :div, :style => style_for(footer_style) do
      yield
    end
  end
  
  def h1
    content_tag :h1, :style => style_for(h1_style) do
      yield
    end
  end
  
  def h2
    content_tag :h2, :style => style_for(h2_style) do
      yield
    end
  end
  
  def hr
    tag :hr, :style => style_for(hr_style)
  end
  
  def link url
    content_tag :a, :href => url, :style => style_for(a_style) do
      yield
    end
  end
  
  def small_orange_link url
    content_tag :a, :href => url, :style => style_for(a_orange_style.merge(small_style)) do
      yield
    end
  end
  
  def orange_button
    content_tag :button, :style => style_for(orange_button_style) do
      yield
    end
  end
  
  private
  
  def style_for styles
    styles.inject(""){|r, (k,v)| r + "#{k}:#{v};"}
  end
  
  def body_style
    {
      'background' => "#ffffff",
      'font-family' => "Arial, Helvetica, sans-serif",
      'font-size' => "14px",
      'color' => "black",
      'width' => "500px"
    }
  end
  
  def header_style
    {
  		'height' => "80px",
  		'margin-bottom' => "20px",
  		'margin-top' => "5px"
	  }
  end
  
  def content_style
    {
      'padding-left' => "10px",
		  'padding-bottom' => "15px"
	  }
  end
  
  def footer_style
    {
      'color' => "#666666"
    }
  end

  def h1_style
    {
      'font-size' => "20px",
      'font-weight' => "normal"
    }
  end
  
  def h2_style
    {
      'font-size' => "14px",
		  'font-weight' => "normal"
	  }
  end

  def a_style
    {
      'color' => "black",
		  'text-decoration' => "none"
	  }
  end
  
  def a_orange_style
    {
      'color' => "#FF6600",
  		'text-decoration' => "none"
    }
  end
  
  def small_style
    {
      'font-size' => "11px"
    }
  end
  
  def hr_style
    {
      'border' => "0",
  		'height' => "1px",
  		'color' => "#dddddd",
  		'background' => "#dddddd",
  		'position' => "relative",
  		'margin' => "3px 0px"
    }
  end
  
  def orange_button_style
    {
      'text-shadow' => "0px -1px 0px #fe3700",
      'padding' => "5px 8px",
      'border' => "1px solid #fe3700",
      'box-shadow' => "0 1px 2px 1px rgba(0, 0, 0, 0.2)",
      'border-radius' => "4px",
      'background-color' => "#FE7F1D",
      'color' => "white",
      'cursor' => "pointer",
      'height' => "30px",
      'margin' => "4px 2px",
      'display' => "inline-block",
      'position' => "relative"
    }
  end
end