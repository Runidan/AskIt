class QuestionDecorator < Draper::Decorator
  delegate_all
  
  def formatted_created_at
    created_at.strftime('%y-%m-%d %H:%M:%S')
  end
end
