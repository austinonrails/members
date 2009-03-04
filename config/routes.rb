ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => 'members'
  
  map.resources :members, :collection => {:list => :get}
  map.resources :topics, :member => {:enthusiasts => :get, :experts => :get, :speakers => :get} do |topic|
    topic.resources :interests, :controller => "MemberInterests"
  end

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "members"
  map.logout '/logout', :controller => 'members', :action => 'logout'
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
