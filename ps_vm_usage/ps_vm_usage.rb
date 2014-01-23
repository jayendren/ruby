#!/usr/bin/env ruby

# calculate the total vm usage for each line in
# linux/freebsd: ps auxww|grep pattern|awk {'print $5'}
# sunos: ps -ef -o user -o vsz -o fname|grep pattern|awk {'print $2'}
# author: Jayendren Maduray <jayendren@gmail.com>

require 'facter'

operatingsystem = Facter.value('operatingsystem')

total = 0
pattern = ARGV[0]
unless pattern.to_s.empty?

  case operatingsystem
    when /^Solaris$/
      ps_swap = `ps -ef -o user -o vsz -o fname|grep #{pattern}|grep -v grep|awk {'print $2'}`.split("\n").map(&:to_i)
    when /^RedHat$|^CentOS$|^FreeBSD$|^Darwin$/
      ps_swap = `ps auxww|grep #{pattern}|grep -v grep|awk {'print $5'}`.split("\n").map(&:to_i)
    else
      printf "unsupported OS: %s \n" % [ operatingsystem]
      exit 1
  end

  ps_swap.each {|use|
    total += use
  }

  printf "#{pattern} proc vm usage: %sKB %sMB %sGB\n" % [ total, (total / 1024), ((total / 1024) / 1024) ]

else
  printf "usage: #{$0} java\n"
end
