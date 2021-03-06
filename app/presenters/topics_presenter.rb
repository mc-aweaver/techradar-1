class TopicsPresenter
  def initialize(topics)
    @topics = topics
  end

  def each_letter
    grouped_topics.each do |letter, topics|
      yield letter, topics
    end
  end

  protected

  attr_reader :topics

  private

  def grouped_topics
    topics.group_by do |topic|
      topic.name[0].upcase
    end
  end
end
