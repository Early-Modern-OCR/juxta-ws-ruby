juxta-ws-ruby
=============

Requires ruby 1.9.2 or higher

gem install juxta


# load ruby bindings

require 'juxta'
juxta = Juxta.new( "http://ws.juxtasoftware.org" )

# get into your workspace

juxta.create_workspace("foo")
juxta.select_workspace("foo")

# upload witness

src_id = juxta.upload_source( file )

# transform them using default xslt

wit_id = juxta.transform_source( src_id )

# create arrays for storing ids

wit_ids = []
wit_ids.push( wit_id )

# load witnesses from URL



# create a custom xslt


# create a set

set_id = juxta.make_set( wit_ids )

# tokenize the set

juxta.tokenize_set( set_id )

# adjust tokenization settings

# collate them

juxta.collate_set( set_id )

# view the result

# you can also perform simple searches

# and you can annotate..

# have fun!
