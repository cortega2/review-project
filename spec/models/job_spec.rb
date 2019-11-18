require 'rails_helper'

RSpec.describe Job, type: :model do
  context 'Factory' do
    it 'has a valid factory' do
      expect(FactoryBot.build(:job).save).to be true
    end
  end
end

