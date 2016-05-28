require 'csv'
i = 0
arr = []
prom = 0
CSV.foreach("file.csv", converters: :numeric, headers: :false) do |row|
  arr << row[0]
  @prom = arr.inject{ |sum, el| sum + el }.to_f / arr.size
end
puts arr.inspect
puts prom

CSV.open("file.csv", "w") do |csv|
  csv << ["", "", "#{@prom}"]
end
