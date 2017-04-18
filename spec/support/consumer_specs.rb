# frozen_string_literal: true

module ConsumerSpecBehavior
  def consumer
    described_class.new
  end

  def publish(data)
    consumer.process(data)
  end
end
