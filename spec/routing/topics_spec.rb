require "spec_helper"

describe TopicsController do 
	it "should route to search" do
		expect(get: "/topics/search").to route_to(controller: "topics", action: "search")
	end
	context "members" do
		it "should route to enthusiasts" do
			expect(get: "/topics/1/enthusiasts").to route_to(controller: "topics", action: "enthusiasts", id: "1")
		end
		it "should route to experts" do
			expect(get: "/topics/1/experts").to route_to(controller: "topics", action: "experts", id: "1")
    end
		it "should route to speakers" do
		  expect(get: "topics/1/speakers").to route_to(controller: "topics", action: "speakers", id: "1")
		end
		it "should route to autocompete" do
			expect(get: "topics/1/auto_complete_for_topic_name").to route_to(controller: "topics", action: "auto_complete_for_topic_name", id: "1")
		end
	end
end