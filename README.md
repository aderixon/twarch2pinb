# Summary

`twarch2pinb.rb` will iterate over the data from your Twitter archive and
post any links it finds in your tweets to Pinboard as bookmarks. It
preserves the original tweeted timestamp and any hashtags.

twarch2pinb is a dirty hack and has a terrible name. It is intended for
one-time use only, given that the normal Pinboard/Twitter integration will
accomplish this automatically for all ongoing tweets and the previous 3200
(up to the Twitter API limit).

twarch2pinb will attempt to resolve all the URLs it finds to their final
canonical target, rather than the shortened links typically posted to
Twitter, using the LongURL service and direct lookups. In some
cases, you will find that certain URLs can no longer be resolved or do not
redirect to the original page; dealing with these is left as an exercise
for the user. (The original, untouched URL is always included as part of
the tweeted text.)

In the case of retweets, twarch2pinb will use your (usually abridged) RT
text as the description for the bookmark, with the original tweet inserted
in Pinboard's extended description field.

twarch2pinb does not perform any filtering on the links it finds; *all*
tweeted links, including media and autoposted tweets such as Tweeklyfm,
will be bookmarked.

# Usage

First, request your Twitter archive from your account (under Settings).
Once you have downloaded it, unpack the archive and locate the
data/js/tweets/ subdirectory.

Edit the twarch2pinb.rb script and insert your Pinboard API token in the
appropriate place. Review the included modules and ensure that you have
the relevant Ruby gems installed (principally json, pinboard, longurl and
htmlentities).

Run the script over some or, if you're feeling brave, all of the
timestamped JSON files in your archive, e.g.:

    twarch2pinb.rb 2010_05.js
    twarch2pinb.rb *.js

(I strongly suggest that you try a small archive first and review the
results.)

The script will occasionally complain about being unable to resolve
particular URIs; these can usually be ignored, but often serve to indicate
obsolete or non-functioning links. (In these cases, the original URI is
included unmodified in the bookmark.)

If you run this script multiple times over the same data, it will
*probably* just replace the existing bookmarks with identical ones (but be
aware that canonical URLs sometimes turn out to embed a unique session ID,
which will cause multiple bookmarks to be generated).

This script will take some time to run over a large number of archived
tweets, due to the rate limiting imposed on the Pinboard API.

# Support

You can see many ways to improve this script and you're a much better Ruby
coder than me (which is quite likely unless you're a blind, incontinent
feline)? Splendid, you're definitely the person to write a better version.
Go on, spit-spot.
