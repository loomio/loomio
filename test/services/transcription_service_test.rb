require "test_helper"
require "stringio"

class TranscriptionServiceTest < ActiveSupport::TestCase
  setup do
    CACHE_REDIS_POOL.with { |client| client.flushall }
  end

  test "returns transcription response" do
    with_openai_key do
      audio = Object.new
      audio.define_singleton_method(:transcribe) do |parameters:|
        { "text" => "hello", "language" => "en" }
      end

      client = Object.new
      client.define_singleton_method(:audio) { audio }

      OpenAI::Client.stub(:new, client) do
        response = TranscriptionService.transcribe(StringIO.new("audio"))

        assert_equal "hello", response["text"]
        assert_equal "en", response["language"]
      end
    end
  end

  test "limits trial users to 3 transcriptions per day" do
    with_openai_key do
      user = fake_user(id: 101, paying: false)
      transcriptions = 0
      client = fake_openai_client { transcriptions += 1 }

      OpenAI::Client.stub(:new, client) do
        Rails.logger.stub(:info, nil) do
          3.times do
            assert_equal "hello", TranscriptionService.transcribe(StringIO.new("audio"), user: user)["text"]
          end

          assert_nil TranscriptionService.transcribe(StringIO.new("audio"), user: user)
        end
      end

      assert_equal 3, transcriptions
    end
  end

  test "limits paying users to 30 transcriptions per day" do
    with_openai_key do
      user = fake_user(id: 201, paying: true)
      transcriptions = 0
      client = fake_openai_client { transcriptions += 1 }

      OpenAI::Client.stub(:new, client) do
        Rails.logger.stub(:info, nil) do
          30.times do
            assert_equal "hello", TranscriptionService.transcribe(StringIO.new("audio"), user: user)["text"]
          end

          assert_nil TranscriptionService.transcribe(StringIO.new("audio"), user: user)
        end
      end

      assert_equal 30, transcriptions
    end
  end

  test "returns nil when OpenAI rate limits transcription" do
    with_openai_key do
      audio = Object.new
      audio.define_singleton_method(:transcribe) do |parameters:|
        raise Faraday::TooManyRequestsError.new("rate limit")
      end

      client = Object.new
      client.define_singleton_method(:audio) { audio }

      OpenAI::Client.stub(:new, client) do
        Rails.logger.stub(:warn, nil) do
          assert_nil TranscriptionService.transcribe(StringIO.new("audio"))
        end
      end
    end
  end

  private

  FakeUser = Struct.new(:id, :paying) do
    def is_paying?
      paying
    end
  end

  def fake_user(id:, paying:)
    FakeUser.new(id, paying)
  end

  def fake_openai_client
    audio = Object.new
    audio.define_singleton_method(:transcribe) do |parameters:|
      yield
      { "text" => "hello", "language" => "en" }
    end

    client = Object.new
    client.define_singleton_method(:audio) { audio }
    client
  end

  def with_openai_key
    previous_key = ENV["OPENAI_API_KEY"]
    ENV["OPENAI_API_KEY"] = "test-key"
    yield
  ensure
    ENV["OPENAI_API_KEY"] = previous_key
  end
end
