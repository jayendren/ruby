#!/usr/bin/env ruby
# calculate the total vm usage for each line in
# ps auxww|grep pattern|awk {'print $5'}

total = 0
pattern = ARGV[0]
if pattern.to_s.empty?
  printf "usage: #{$0} java\n"
else
  ps_swap = `ps auxww|grep #{pattern}|grep -v grep|awk {'print $5'}`.split("\n").map(&:to_i)
  ps_swap.each {|use|
    total += use
  }
  printf "#{pattern} proc vm usage: %sKB %sMB %sGB\n" % [ total, (total / 1024), ((total / 1024) / 1024) ]
end
