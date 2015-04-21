require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end

      describe "posting the 1st micropost" do
        before do
          user.microposts.delete_all
          click_button "Post" 
        end
        it { should have_selector('span', text: /1 micropost$/) }

        describe "posting the 2nd micropost" do
          before do
          fill_in 'micropost_content', with: "Lorem ipsum"
          click_button "Post"
          end
          it { should have_selector('span', text: /2 microposts$/) }
        end
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end

    describe "as wrong user" do 
      let(:wrong_user) { FactoryGirl.create(:user) }
      before { visit user_path(wrong_user) }
      
      it { should_not have_link "delete" }
    end
  end
end

describe "Micropost pagination" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before do
    50.times { user.microposts.create!(content: Faker::Lorem.sentence(5)) }
    sign_in user
  end
  
  it { should have_selector('div.pagination') }
  
  it "should list each micropost" do
    user.microposts.paginate(page: 1).each do |micropost|
      expect(page).to have_selector('span.content', text: micropost.content)
    end
  end
end
