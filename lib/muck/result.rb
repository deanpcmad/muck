module Muck
  class Result
    attr_reader :database, :error

    def initialize(database, error = nil)
      @database = database
      @error = error
    end

    def success?
      error.nil?
    end
  end
end
