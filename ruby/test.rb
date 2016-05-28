tally = Hash.new(0)
File.open('gettysburg.txt').each_line do |line|
  line.downcase.split(/\W+/).each { |w| tally[w] += 1 }
end
total = tally.values.inject { |sum,count| sum + count }
tally.delete_if { |key,count| count < 3 || key.length < 4 }

require "rinruby"
R.keys, R.counts = tally.keys, tally.values

R.eval <<EOF
names(counts) <- keys
barplot(rev(sort(counts)),main="Frequency of Non-Trivial Words",las=2)
mtext("Among the #{total} words in the Gettysburg Address",3,0.45)
rho <- round(cor(nchar(keys),counts),4)
EOF

puts "The correlation between word length and frequency is #{R.rho}."
