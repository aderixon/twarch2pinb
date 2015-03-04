#!/usr/bin/ruby
# $Id$
#
# Script:	twarch2pinb.rb
#
# Description:	Parse Twitter archive JSON, post links to Pinboard
#		Partly based on:
#		http://rubyist.g.hatena.ne.jp/hatecha/20130322/tweetsjson
#		Somebody stop me before I do any more Ruby like this
#
# Usage:
# 		twarch2pinb.rb *.js
#		(for all data/js/tweets/ files in Twitter archive)
#
# Author:	ajr
# 
# History:
# 		Created - 2015-03-02
#

# Pinboard API details, get yours from https://pinboard.in/settings/password
pintoken = 'YOUR_API_TOKEN'

require 'json'
require 'time'
require 'date'
require 'pinboard'
require 'uri'
require 'longurl'
require 'htmlentities'

pinclnt = Pinboard::Client.new(:token => pintoken)
coder = HTMLEntities.new

ARGV.each{|file|

  # skip header line
  data=File.read(file).sub(/^Grailbird.data.tweets_([^=]*)=/){}
  j=JSON.parse(data)
  j.each{|tweet|

    item=tweet
    desc=item["text"]
    extended=nil
    d=DateTime.parse(item["created_at"])
    if item["retweeted_status"]
      # unwrap retweet
      item=item["retweeted_status"]
      extended=item["text"]	# original RT text used for extended desc
    end

    entities=item["entities"]
    urls=entities["urls"]
    if urls.size > 0
      link=urls[0]["expanded_url"]
    else
      # urls entity unused in older tweets, extract any links from text instead
      link=URI.extract(item["text"], /http[s]?/)[0]
    end
    ## gather multiple URLs (unused)
    #links=[]
    #urls.each{|u|
    #  links.push(u["expanded_url"])
    #}

    # extract all hashtag text fields
    tags=entities["hashtags"]
    tagtext=[]
    tags.each{|tag|
      tagtext.push(tag["text"])
    }

    if link
      # try to resolve link to final URI
      begin
        linkr=LongURL.expand(link)
        if linkr
          link=linkr
        end
      rescue
        # couldn't resolve, use as-is
        $stderr.puts "Couldn't resolve #{link}"
      end

      # DEBUG:
      #puts "#{d.strftime("%Y-%m-%d %H:%M:%S")} #{coder.decode(item["text"])} #{link} #{tagtext.join(",")}"
      # try to post link to pinboard (four attempts)
      tries=0
      begin
        tries += 1
        pinclnt.add(:url => link, :description => coder.decode(desc), :dt => d, :tags => tagtext, :extended => coder.decode(extended))
      rescue
        $stderr.puts "Couldn't post #{link} on try #{tries}"
        if (tries < 4)
          sleep(2**tries)	# back-off
          retry
        end
      end
      sleep 4	# stay under Pinboard API rate limit
    end

  }

}
