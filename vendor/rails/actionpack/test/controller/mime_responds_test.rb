require File.dirname(__FILE__) + '/../abstract_unit'

class RespondToController < ActionController::Base
  layout :set_layout

  def html_xml_or_rss
    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.xml  { render :text => "XML"     }
      type.rss  { render :text => "RSS"     }
      type.all  { render :text => "Nothing" }
    end
  end
  
  def js_or_html
    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.js   { render :text => "JS"      }
      type.all  { render :text => "Nothing" }
    end
  end

  def html_or_xml
    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.xml  { render :text => "XML"     }
      type.all  { render :text => "Nothing" }
    end
  end
  
  def just_xml
    respond_to do |type|
      type.xml  { render :text => "XML" }
    end
  end
  
  def using_defaults
    respond_to do |type|
      type.html
      type.js
      type.xml
    end
  end
  
  def using_defaults_with_type_list
    respond_to(:html, :js, :xml)
  end
  
  def made_for_content_type
    respond_to do |type|
      type.rss  { render :text => "RSS"  }
      type.atom { render :text => "ATOM" }
      type.all  { render :text => "Nothing" }
    end
  end

  def custom_type_handling
    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.custom("application/crazy-xml")  { render :text => "Crazy XML"  }
      type.all  { render :text => "Nothing" }
    end
  end

  def handle_any
    respond_to do |type|
      type.html { render :text => "HTML" }
      type.any(:js, :xml) { render :text => "Either JS or XML" }
    end
  end

  def all_types_with_layout
    respond_to do |type|
      type.html
      type.js
    end
  end

  def rescue_action(e)
    raise
  end
  
  protected
    def set_layout
      if action_name == "all_types_with_layout"
        "standard"
      end
    end
end

RespondToController.template_root = File.dirname(__FILE__) + "/../fixtures/"

class MimeControllerTest < Test::Unit::TestCase
  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @controller = RespondToController.new
    @request.host = "www.example.com"
  end
  
  def test_html
    @request.env["HTTP_ACCEPT"] = "text/html"
    get :js_or_html
    assert_equal 'HTML', @response.body
    
    get :html_or_xml
    assert_equal 'HTML', @response.body

    get :just_xml
    assert_response 406
  end

  def test_all
    @request.env["HTTP_ACCEPT"] = "*/*"
    get :js_or_html
    assert_equal 'HTML', @response.body # js is not part of all

    get :html_or_xml
    assert_equal 'HTML', @response.body

    get :just_xml
    assert_equal 'XML', @response.body
  end

  def test_xml
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :html_xml_or_rss
    assert_equal 'XML', @response.body
  end

  def test_js_or_html
    @request.env["HTTP_ACCEPT"] = "text/javascript, text/html"
    get :js_or_html
    assert_equal 'JS', @response.body

    get :html_or_xml
    assert_equal 'HTML', @response.body

    get :just_xml
    assert_response 406
  end

  def test_js_or_anything
    @request.env["HTTP_ACCEPT"] = "text/javascript, */*"
    get :js_or_html
    assert_equal 'JS', @response.body

    get :html_or_xml
    assert_equal 'HTML', @response.body

    get :just_xml
    assert_equal 'XML', @response.body
  end
  
  def test_using_defaults
    @request.env["HTTP_ACCEPT"] = "*/*"
    get :using_defaults
    assert_equal 'Hello world!', @response.body

    @request.env["HTTP_ACCEPT"] = "text/javascript"
    get :using_defaults
    assert_equal '$("body").visualEffect("highlight");', @response.body

    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :using_defaults
    assert_equal "<p>Hello world!</p>\n", @response.body
  end
  
  def test_using_defaults_with_type_list
    @request.env["HTTP_ACCEPT"] = "*/*"
    get :using_defaults_with_type_list
    assert_equal 'Hello world!', @response.body

    @request.env["HTTP_ACCEPT"] = "text/javascript"
    get :using_defaults_with_type_list
    assert_equal '$("body").visualEffect("highlight");', @response.body

    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :using_defaults_with_type_list
    assert_equal "<p>Hello world!</p>\n", @response.body
  end
  
  def test_with_content_type
    @request.env["CONTENT_TYPE"] = "application/atom+xml"
    get :made_for_content_type
    assert_equal "ATOM", @response.body

    @request.env["CONTENT_TYPE"] = "application/rss+xml"
    get :made_for_content_type
    assert_equal "RSS", @response.body
  end
  
  def test_synonyms
    @request.env["HTTP_ACCEPT"] = "application/javascript"
    get :js_or_html
    assert_equal 'JS', @response.body

    @request.env["HTTP_ACCEPT"] = "application/x-xml"
    get :html_xml_or_rss
    assert_equal "XML", @response.body
  end
  
  def test_custom_types
    @request.env["HTTP_ACCEPT"] = "application/crazy-xml"
    get :custom_type_handling
    assert_equal 'Crazy XML', @response.body

    @request.env["HTTP_ACCEPT"] = "text/html"
    get :custom_type_handling
    assert_equal 'HTML', @response.body
  end

  def test_xhtml_alias
    @request.env["HTTP_ACCEPT"] = "application/xhtml+xml,application/xml"
    get :html_or_xml
    assert_equal 'HTML', @response.body
  end
  
  def test_firefox_simulation
    @request.env["HTTP_ACCEPT"] = "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5"
    get :html_or_xml
    assert_equal 'HTML', @response.body
  end

  def test_handle_any
    @request.env["HTTP_ACCEPT"] = "*/*"
    get :handle_any
    assert_equal 'HTML', @response.body

    @request.env["HTTP_ACCEPT"] = "text/javascript"
    get :handle_any
    assert_equal 'Either JS or XML', @response.body

    @request.env["HTTP_ACCEPT"] = "text/xml"
    get :handle_any
    assert_equal 'Either JS or XML', @response.body
  end
  
  def test_all_types_with_layout
    @request.env["HTTP_ACCEPT"] = "text/javascript"
    get :all_types_with_layout
    assert_equal 'RJS for all_types_with_layout', @response.body

    @request.env["HTTP_ACCEPT"] = "text/html"
    get :all_types_with_layout
    assert_equal '<html>HTML for all_types_with_layout</html>', @response.body
  end

  def test_xhr
    xhr :get, :js_or_html
    assert_equal 'JS', @response.body

    xhr :get, :using_defaults
    assert_equal '$("body").visualEffect("highlight");', @response.body
  end
end
