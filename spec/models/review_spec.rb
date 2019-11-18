require 'rails_helper'

RSpec.describe Review, type: :model do
  context 'Factory' do
    it 'has a valid factory' do
      expect(FactoryBot.build(:review).save).to be true
    end
  end

  context 'when a brand id is used more than once' do
    it 'will be invalid' do
      FactoryBot.create(:review)
      review = FactoryBot.build(:review)
      expect(review.invalid?).to be(true)
    end

    it "will have a brand id unique error" do
      FactoryBot.create(:review)
      review = FactoryBot.build(:review)

      # need to do this to populate the errors fields
      review.valid?

      field = :brand_id
      expect(review.errors.messages[field][0]).to eq("has already been taken")
    end
  end
end
