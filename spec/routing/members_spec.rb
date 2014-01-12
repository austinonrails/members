require "spec_helper"

describe MembersController do 
	it "should have routes for list" do
		expect(get: "/members/list").to route_to(controller: "members", action: "list")
	end
	it "should have routes for search" do
		expect(get: "/members/search").to route_to(controller: "members", action: "search")
	end
end