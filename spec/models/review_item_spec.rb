require 'rails_helper'

RSpec.describe ReviewItem, type: :model do
  context 'Factory' do
    it 'has a valid factory' do
      expect(FactoryBot.build(:review_item).save).to be true
    end
  end
end
