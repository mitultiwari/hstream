class Login < ActiveRecord::Base
  def merge_shortlist(s)
    self[:shortlist] = (shortlist.split(',')+s.split(',')).uniq.join(',')
    save
  end
end
