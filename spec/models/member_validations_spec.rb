require "spec_helper"

describe "Member Validations" do
  context "first name validations" do  
    it "should not be blank" do
      member = Member.create(first_name: "Damon")
      expect(member.first_name).to eq("Damon")
    end    
    it "when invalid should have 1 error message" do
      member = Member.create(first_name: "")
      expect(member.errors.messages[:first_name]).to have(1).error
    end
    it "when invalid should error message of \"can't be blank\"" do
      member = Member.create(first_name: "")
      expect(member.errors.messages[:first_name]).to eq(["can't be blank"])
    end
  end

  context "last name validations" do  
    it "should not be blank" do
      member = Member.create(last_name: "Clinkscales")
      expect(member.last_name).to eq("Clinkscales")
    end
    it "when invalid should have 1 error message" do
      member = Member.create(last_name: "")
      expect(member.errors.messages[:last_name]).to have(1).error
    end
    it "when invalid should error message of \"can't be blank\"" do
      member = Member.create(last_name: "")
      expect(member.errors.messages[:last_name]).to eq(["can't be blank"])
    end
  end
   
  context "email validations" do
    it "valid when it is bob@example.com with no errors on email" do
      member = Member.create(email: "bob@example.com")
      expect(member.errors.messages[:email]).to be_nil
    end
    it "when blank should have at least 1 error message" do
      member = Member.create(email: "")
      expect(member.errors.messages[:email].size).to be >= 1
    end
    it "when blank should error message of \"can't be blank\"" do
      member = Member.create(email: "")
      expect(member.errors.messages[:email]).to include("can't be blank")
    end
    it "have error message \"should look like an email\" when it is bob.com" do
      member = Member.create(email: "bob.com")
      expect(member.errors.messages[:email]).to include("should look like an email address.")
    end
    it "have error message \"should look like an email\" when it is bob" do
      member = Member.create(email: "bob")
      expect(member.errors.messages[:email]).to include("should look like an email address.")
    end
    it "should not have members with the same email" do
      FactoryGirl.create(:member, email: "bob@example.com")
      expect{FactoryGirl.create(:member, email: "bob@example.com")}.to raise_error(ActiveRecord::RecordInvalid)     
      expect(Member.count).to be 1
    end    
  end
end