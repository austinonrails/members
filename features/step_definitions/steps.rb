Given(/^I am on the Login page$/) do
  visit login_path
end

When(/^I click on Forgot Password$/) do
  click_link "Reset my password"
end

Then(/^I should see Forgot Password$/) do
  page.should have_content "Forgot Password" 
end

Then(/^I fill in email with my address$/) do
  @user = FactoryGirl.create(:member, email: 'test@test.com')
  fill_in :email, with: "test@test.com"
end

Then(/^I use the url to go to change password page$/) do
  visit edit_password_reset_path(id: @user.perishable_token)
end

Then(/^fill in a new password and confirmation$/) do
  fill_in :member_password, with: "foo12345"
  fill_in :member_password_confirmation, with: "foo12345"  
end
