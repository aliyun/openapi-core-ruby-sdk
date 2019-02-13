# in spec/hello_spec.rb
require "hello"

RSpec.describe do
  describe 'hello' do
    it 'returns Hello, Ruby.' do
      expect(hello).to eq("Hello, Ruby.")
    end
  end
end