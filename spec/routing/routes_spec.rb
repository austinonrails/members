require "spec_helper"

describe "root routes" do
  context "password_resets" do
  	it "should create a reset" do
      expect(post: "/password_resets").to route_to(controller: 'password_resets', action: 'create') 
     end
    it "should do the rest" do
      expect(put: "/password_resets/1").to route_to(controller: 'password_resets', action: 'update', id: '1')
    end
  end
  context "should route to member_sessions" do
  	it "should initialize a new session" do
      expect(get: "/member_sessions/new").to route_to(controller: 'member_sessions', action: 'new')
  	end
    it "should create a new session" do
      expect(post: "/member_sessions").to route_to(controller: 'member_sessions', action: 'create')
    end
    it "should destroy a session" do
      expect(delete: "/member_sessions/1").to route_to(controller: 'member_sessions', action: 'destroy', id: "1")
    end
  end
  it "should route to login" do
    expect(get: "/login").to route_to(controller: 'member_sessions', action: 'new')
  end 
  it "should route to logout" do
    expect(get: "/logout").to route_to(controller: 'member_sessions', action: 'destroy')
  end
  it "should route root to members#index"	do
    expect(get: "/").to route_to(controller: 'members', action: 'index')
  end
end