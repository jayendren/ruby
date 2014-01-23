#!/usr/bin/env ruby

# About:
#  scrapper to download MP3's from http://www.ektoplazm.com/style/genre based on rating
#
# Requires:
#  rubygems:
#   nokogiri, open-uri, colorize
#  download manager:
#   axel or wget (update @dlmgmr variable with path)
#
# Sample usage:
#  Interactive:
#   ./ekto_scaper
#
#  CLI:
#   ./ekto_scaper --url 'http://www.ektoplazm.com/style/progressive' --rating '95'
#
# Sample output:
#
# └─[$] <> ./ekto.rb --url http://www.ektoplazm.com/style/progressive --rating 96                                                                                             130 ↵
# DBG: URL: http://www.ektoplazm.com/style/progressive - RATING: 96
#
# loading...please wait.
#
#
# === Progressive Releases at Ektoplazm ===
#
# Release:                                                          Rating:              Status:                   Completed:
#
# DJ Basilisk – Replicant Redux                                     93                   skipping                  98.076923
# 
# DJ Basilisk – Nocturnal Wanderlust                                96                   starting                  100.000000
# Initializing download: http://www.ektoplazm.com/files/DJ%20Basilisk%20-%20Nocturnal%20Wanderlust.mp3
# File size: 191565824 bytes
# Opening output file DJ Basilisk - Nocturnal Wanderlust.mp3.0
# Starting download
#
# Connection 1 finished                                                          ]
# Connection 3 finished                                                          ]
# Connection 2 finished                                                          ]
# Connection 0 finished                                                          ]
#
# Downloaded 182.7 megabytes in 5:01 seconds. (621.36 KB/s)

# Author: Jayendren Maduray <jayendren@gmail.com>

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'colorize'

# GLOBAL VARIABLES
@rating = 95
@dlmgmr = "axel -a"

def ekto_input

  if (ARGV[0].to_s.match(/^\-\-help$/))

    cmd = $0

    printf "About:\n".blue
    printf "Ruby (nokogiri) scraper for www.ektoplazm.com \n".green
    printf "Use case: \n".green
    printf "1. Scan all pages on http://www.ektoplazm.com/style/progressive\n\n".green
    printf "2. Find and download all MP3 packs with rating > 95%\n".green

    printf "Usage:\n".blue
    printf "Interactive:     #{cmd}\n".green
    printf "CLI        :     #{cmd} --url 'http://www.ektoplazm.com/style/progressive' --rating '95'\n\n".green
    exit 0

  elsif (ARGV[0].to_s.match(/^\-\-url$/))

    unless (ARGV[1].to_s.empty?) or ! (ARGV[1].to_s.match(/^http\:\/\/www\.ektoplazm\.com\/style\//))
      @ekto_url = ARGV[1]
    else 
      puts "invalid url !".red; exit 1
    end

    if (ARGV[2].to_s.match(/^\-\-rating$/))

      unless (ARGV[3].to_s.empty?) or ! (ARGV[3].to_i < 100)   
        @ekto_rating = ARGV[3]   
      else 
        puts "rating cannot be > 100 !".red; exit 1
      end        

    end

  else

    printf "Interactive mode started: \n\n".cyan
    printf "Type ektoplazm URL > ".green

    @ekto_url = gets.strip.to_s
    unless ! @ekto_url.match(/^http\:\/\/www\.ektoplazm\.com\/style\//)
      printf "Type the rating: > ".green
      @ekto_rating  = gets.strip.to_s

      unless ! (@ekto_rating.to_i < 100)
        printf "\n"
      else 
        puts "rating cannot be > 100 !".red; exit 1
      end

    else 
      puts "invalid url !".red; exit 1
    end 

  end  
  puts "DBG: URL: #{@ekto_url} - RATING: #{@ekto_rating}\n".green
  puts "loading...please wait.\n".green

end #def

def ekto_scrape(ekto_url,ekto_rating)
  url     = ekto_url  
  @rating = ekto_rating.to_i
  @doc    = Nokogiri::HTML(open(url))
  pgs     = @doc.css(".navigation").css(".pages").text.split(/\s/)[-1].to_i
  post    = @doc.css(".post")

  printf "\n===\s%s===\n\n".blue % [ @doc.at_css("title").text.split(/\-/)[0], pgs - pgs + 1 ]
  printf "%-65s %-20s %-25s %-2s\n\n".cyan % [ 'Release:', 'Rating:', 'Status:', 'Completed:']

  #page 1
  post.each {|d|
    title = d.css("h1").css("a").text
    score = d.css("strong").to_s.split(/\>|\%/)[-4].to_i
    dll   = d.css(".dll").css("a").to_s.split(/\"/)[1]

    unless score < @rating
      printf "%-65s %-20s %-25s %-1f\n".cyan % [ title, score, 'starting', ((1 / pgs.to_f) * 100).to_f ]
      system("#{@dlmgmr} #{dll}")
      puts 
    else 
      printf "%-65s %-20s %-25s %-1f\n".red % [ title, score, 'skipping', ((1 / pgs.to_f) * 100).to_f ]
    end 
    puts
  }

  #remaining pages
  for pages in 2..pgs

    url = "#{ekto_url}/page/#{pages}"
    @doc = Nokogiri::HTML(open(url))

    post = @doc.css(".post")
    post.each {|d|
      title = d.css("h1").css("a").text
      score = d.css("strong").to_s.split(/\>|\%/)[-4].to_i
      dll   = d.css(".dll").css("a").to_s.split(/\"/)[1]

      unless score < @rating
        printf "%-65s %-20s %-25s %-1f\n".cyan % [ title, score, 'starting', ((pages.to_f / pgs.to_f) * 100).to_f ]
        system("#{@dlmgmr} #{dll}")
        puts 
      else 
        printf "%-65s %-20s %-25s %-1f\n".red % [ title, score, 'skipping', ((pages.to_f / pgs.to_f) * 100).to_f ]
      end 
      puts
    }

    end #for pages

  end #def

  ## MAIN ##
  begin
    ekto_input
    ekto_scrape(@ekto_url,@ekto_rating)
  end
