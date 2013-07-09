## Juxta Ruby Gem 

Juxta WS can collate two or more versions of the same textual work (“witnesses”) and generate a list of alignments as well as two different styles of visualization suitable for display on the web. The “heat map” visualization shows a base text with ranges of difference from the other witnesses highlighted. The “side by side” visualization shows two of the witnesses in synchronously scrolling columns, with 
areas of difference highlighted.

This gem provides a Ruby interface to the JuxtaWS REST web service. It does not include the Java based Juxta WS webs service. You can download JuxtaWS here:

https://github.com/performant-software/juxta-service 

To install the gem:

    gem install juxta

Examples of use:

	require 'juxta'

	juxta = Juxta.new("http://127.0.0.1:8182")

	# upload a witness from a local file
	src_id = juxta.upload_source( "damozel.xml" )

	# transform using default xslts
	wit_id = juxta.transform_source( src_id )

	# create an array for storing ids
	wit_ids = []
	wit_ids.push( wit_id )

	# load another witnesses from a remote URL
	src_id = juxta.obtain_source_from_url("http://www.rossettiarchive.org/docs/1-1870.2ndedn.prin.rad.xml")
	wit_id = juxta.transform_source( src_id )
	wit_ids.push( wit_id )

	# create a comparison set
	set_id = juxta.make_set( wit_ids )

	# tokenize the texts
	juxta.tokenize_set( set_id )

	# collate the texts
	juxta.collate_set( set_id )

	# view the result
	viz_url = juxta.get_side_by_side_url( set_id, wit_ids[0], wit_ids[1] ) 

	# open web browser on Mac OS 
	system( "open", viz_url )
