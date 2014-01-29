require "spec_helper"

describe Topic do
  context "associations to member" do
     before do
      @member1 = FactoryGirl.create(:member)
      @member2 = FactoryGirl.create(:member, first_name: "bob", last_name: "smith", email: "bob@something.com")
      @topic = FactoryGirl.create(:topic)
      @topic.members << @member1
      @topic.members << @member2
    end

    it "should have 2 members" do
      expect(@topic).to have(2).members
    end
  end

  context "when member already has an interest" do
    before do
      @member = FactoryGirl.create(:member)
      @topic = FactoryGirl.create(:topic)
      @member.topics << @topic
    end

    it "should error when trying to add the same interest again" do
      expect { @member.topics << @topic }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "increase the counts when interest is created" do
    before do
      @member = FactoryGirl.create(:member)
      @topic = FactoryGirl.create(:topic)
    end

    it "when enthusiasts" do
      expect{
        @member.interests << Interest.create(topic: @topic, is_interested: true)
      }.to change{ @topic.enthusiasts.count}.by(1)
    end
    
    it "when expert" do
      expect{
        @member.interests << Interest.create(topic: @topic, is_expert: true)
      }.to change{ @topic.experts.count}.by(1)
    end

    it "when speaker" do
      expect{
        @member.interests << Interest.create(topic: @topic, will_speak: true)
      }.to change{ @topic.speakers.count}.by(1)
    end
  end

end
