require "spec_helper"

describe MemberInterestsController do 
  it "should get a list of interests" do
    expect(get: "/topics/1/interests").to route_to(controller: "member_interests", action: "index", topic_id: "1")
  end 	
  it "should have routes for updating interests" do
  	expect(post: "/topics/1/interests").to route_to(controller: "member_interests", action: "create", topic_id: "1")
  end  	
end