require 'randexp'

50.times do
  topic = Topic.seed(:name) do |t|
    t.name = /\w{5,15}/.gen
    t.created_at = rand(30).days.ago
    t.updated_at = rand(30).days.ago
  end
end