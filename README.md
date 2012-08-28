# bio-bioinformatics-impact

[![Build Status](https://secure.travis-ci.org/pjotrp/bioruby-bioinformatics-impact.png)](http://travis-ci.org/pjotrp/bioruby-bioinformatics-impact)

bio-bioinformatics-impact aims to collect information on researchers
and groups in bioinformatics.

Note: this software is very much a work in progress, your mileage may
vary.

## Step 1: Personal information

If available on Wikipedia, we can fetch personal information through

```bash
  bio-bioinformatics-impact dbpedia --person Lincoln_Stein
```

## Step 2: Fetch impact

Both Google and Microsoft publish citations, and impact indicators.

### Google scholar

Google does not provide an API for Scholar, nor has the intention,
which is a shame. A SPARQL end point would be very useful.

An applet lives at http://code.google.com/p/citations-gadget/, which
is accessed by

```bash
  bio-bioinformatics-impact scholar --author "Lincoln D. Stein"
```

Note: this functionality has not yet been implemented.


### Microsoft academic research

Find an author with a query such as
http://academic.research.microsoft.com/search.html?query=Lincoln%20D.%20Stein 

That should give you the recognized name, e.g. 'Lincoln D. Stein'

The name can be used to fetch the numbers with

```bash
  bio-bioinformatics-impact msimpact --author "Lincoln D. Stein"
    "Name","Publications","Citations","G-index","H-index"
    "Lincoln D. Stein","274","10264","99","45"
```

You can also use the direct link

```bash
  bio-bioinformatics-impact msimpact --link http://academic.research.microsoft.com/Author/28276/lincoln-d-stein
    "Name","Publications","Citations","G-index","H-index"
    "Lincoln D. Stein","274","10264","99","45"
```

To get a long list 

```bash
  bio-bioinformatics-impact msimpact --search "bioinformatics" > list.csv
  sort list.csv |uniq > uniq.csv
  wc uniq.csv
      1129   5728 149255 uniq.csv
```

## Step 3: List publications

bio-bioinformatics-impact takes a pubmed search string as input,
and lists papers of the last 4 years with:

```bash
  bio-rdf pubmed --tabulate --search '(Lincoln Stein[Author]) AND ("2008/01/01"[Date - Publication] : "3000"[Date - Publication])' --pubmed-citations --scholar-citations > Lincoln_Stein.csv
```

using the bio-rdf pubmed feature (part of the bioruby-rdf biogem
package).

## Installation

Not yet implemented. Clone from github if you want to try something.

```sh
    # nyi
    gem install bio-bioinformatics-impact
```

## Usage

```ruby
    # nyi
    require 'bio-bioinformatics-impact'
```

The API doc is online. For more code examples see the test files in
the source tree.
        
## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/pjotrp/bioruby-bioinformatics-impact

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of
  
* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at [#bio-bioinformatics-impact](http://biogems.info/index.html)

## Copyright

Copyright (c) 2012 Pjotr Prins. See LICENSE.txt for further details.

