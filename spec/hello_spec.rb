# in spec/hello_spec.rb
require "hello"

RSpec.describe do
  describe '#add' do
    it 'returns the sum of its arguments' do
      expect(hello).to eq("Hello, Ruby.")
    end
  end
end