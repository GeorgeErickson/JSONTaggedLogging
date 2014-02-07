require 'spec_helper'

describe 'JSONTaggedLogging' do
  class TestLogger
    extend Forwardable
    def_delegators :logger, :tagged
    attr_accessor :log, :logger

    def initialize
      @log = StringIO.new
      @logger = JSONTaggedLogging.new ActiveSupport::Logger.new(log)
    end

    def msg
      log.string.split("\n").last.strip
    end

    def info(message)
      @logger.info(message)
      msg
    end
  end

  subject(:logger) { TestLogger.new }

  let(:message) { 'message' }

  RSpec::Matchers.define :be_tagged_with do |tags|
    match do |logger|
      logger.info(message) == "[#{JSON.dump(tags)}] #{message}"
    end
  end

  RSpec::Matchers.define :be_untagged do
    match do |logger|
      logger.info(message) == message
    end
  end

  it "Logs basic messages." do
    expect(logger).to be_untagged
  end

  it "Tags correctly" do
    expect(logger).to be_untagged

    logger.tagged(a: 'A') do
      expect(logger).to be_tagged_with({a: 'A'})

      logger.tagged({b: 'B'}) do
        expect(logger).to be_tagged_with({a: 'A', b: 'B'})

        logger.tagged(a: '2', c: 'C') do
          expect(logger).to be_tagged_with({a: '2', b: 'B', c: 'C'})
        end
        expect(logger).to be_tagged_with({a: 'A', b: 'B'})
      end
      ({a: 'A'})

      logger.tagged({a: '1'}) do
        expect(logger).to be_tagged_with({a: '1'})
      end
      expect(logger).to be_tagged_with({a: 'A'})
    end
    expect(logger).to be_untagged
  end
end
