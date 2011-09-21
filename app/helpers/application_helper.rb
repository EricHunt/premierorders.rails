module ApplicationHelper
  def time_formatted(time)
    time.strftime("%m-%d-%Y %I:%M%p (AZ)") rescue nil
  end

  def date_formatted(date)
    #date.strftime("%m/%d/%Y") rescue nil
    date.strftime("%m-%d-%Y") rescue nil
  end
end
