require "spec_helper"

describe Member do

  context "associations to topic" do
    before do
      @member = FactoryGirl.create(:member)
      @topic  = FactoryGirl.create(:topic)
      @member.topics << @topic 
    end

    it "should have 1 interest" do
      expect(@member.topics).to have(1).topic
    end

    it "should have 3 interests" do
      @member.topics << FactoryGirl.create(:topic, name:'git')
      @member.topics << FactoryGirl.create(:topic, name:'svn')
      expect(@member.topics).to have(3).topics
    end
  end



end