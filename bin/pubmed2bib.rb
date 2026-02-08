#!/usr/bin/env ruby
#
#
# Use tags such as [au] and [dp]. For a list see
#
#   http://www.ncbi.nlm.nih.gov/books/NBK3827/

$: << ENV['HOME']+'/izip/git/opensource/ruby/bioruby/lib'
# p $:

require 'bio'

write_id=nil
if ARGV[0] == '--id'
  ARGV.shift
  write_id = ARGV.shift
end
keywords = ARGV.join(' ')

options = {
  # 'maxdate' => '2012/01/01',
  'retmax' => 1000,
}

Bio::NCBI.default_email = "pjotr.public01@thebird.nl"
entries = Bio::PubMed.esearch(keywords, options)

Bio::PubMed.efetch(entries).each do |entry|
  medline = Bio::MEDLINE.new(entry)
  reference = medline.reference

  pmcid = 
    if medline.pubmed["PMC"] =~ /(\d+)/
      $1
    else
      nil
    end

  # p reference.authors
  if reference.authors[0] =~ /^(\w+)/
    author = $1.capitalize
  end

  section = 'article'
  write_id = "#{author}:#{reference.year}"
  # bib = "\n@#{section}{PMID:#{reference.pubmed},\n"
  bib = "\n@#{section}{#{write_id},\n"
  bib += "  keywords     = { },\n"
  pmid = reference.pubmed
  bib += "  pmid         = {#{reference.pubmed}},\n" if pmid
  ids = []
  if pmcid
    ids.append "PMC"+pmcid
    bib += "  pmcid        = {#{pmcid}},\n" 
    bib += "  note         = {{PMC#{pmcid}}},\n" 
  elsif pmid
    bib += "  note         = {{PMID: #{pmid}}},\n"
  end
  if pmid
    ids.append("PMID:"+pmid) 
    ids.append("pmid"+pmid) 
  end
  bib += "  IDS          = {" + ids.join(", ") + "},\n"
  keywords = "author title journal year volume number pages doi url abstract".split(/ /)
  keywords.each do | kw |
    if kw == 'author'
      ref = reference.authors.join(' and ')
    elsif kw == 'title'
      # strip final dot from title and add curly braces
      ref = '{'+reference.title.sub(/\.$/,'')+'}'
    elsif kw == 'number'
      ref = reference.issue
    elsif kw == 'abstract'
      ref = reference.abstract.gsub(/%/,"\\%")
    elsif kw == 'url'
     if reference.url and reference.url != ''
       ref = reference.url
     else
       ref = "http://www.ncbi.nlm.nih.gov/pubmed/#{reference.pubmed}" if reference.pubmed
     end
    else
      ref = eval('reference.'+kw)
    end
    bib += "  #{kw.ljust(12)} = {#{ref}},\n" if ref != ''
  end
  if false
  # Fetch citations
  $stderr.print reference.pubmed,"\n"
  res = `lynx --dump "http://www.ncbi.nlm.nih.gov/pubmed/#{reference.pubmed}"`
  res =~ /Cited by( over)? (\d+)/
  cited = $2
  # cited += '+' if $1
  bib += "  pmcited      = #{cited},\n" if cited
  searchfor = reference.doi
  if reference.authors[0]
    searchfor = reference.authors[0] + ' ' + reference.title.chop if searchfor==nil or searchfor == ''
    $stderr.print searchfor
    scholar="lynx --dump \"http://scholar.google.com/scholar?q=#{searchfor}\""
    res = `#{scholar}`
    inpaper=false
    cited = nil
    title = reference.title.chop[0..30]
    res.each_line do | s |
      if !inpaper
        esctitle = title.gsub(/\[/,'\[').gsub(/\(/,'\(')
        inpaper = true if s =~ /#{esctitle}/
      end
      if inpaper and s =~ /Cited by (\d+)/
        cited = $1
        break
      end
    end
  end
  bib += "  gscited      = #{cited},\n" if cited
  bib = bib.strip.chop
  # bib+="  eprint  = {invariants://#{author_year}.pdf},\n"
  end
  bib+="}\n"

  print bib

  # puts reference.nature
end
