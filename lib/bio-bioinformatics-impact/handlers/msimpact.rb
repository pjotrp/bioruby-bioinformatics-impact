require 'bio-logger'
require 'ostruct'
require 'mechanize'
require 'logger'

# Two search domains should be used:
#
# http://academic.research.microsoft.com/Detail?query=bioinformatics&searchtype=1&SearchDomain=2&start=11&end=20
# http://academic.research.microsoft.com/Detail?query=bioinformatics&searchtype=1&SearchDomain=4&start=11&end=20


module BioBioinformaticsImpact
  module MsImpact

    DOMAINS = { 'bioinformatics' => [{"SearchDomain" => 4}, {"SearchDomain" => 2} ]}
    PAGE_SIZE = 100
    module Parser
      include Bio::Log

      def Parser::handler
        log = LoggerPlus.new 'msimpact'
        options = OpenStruct.new()
        # options.author_layout = "surname+', '+initials.join('. ')+'.'"
        # options.authors_join = ", "
        
        example = """
    Examples:

        """
        opts = OptionParser.new() do |o|
          o.banner = "Usage: #{File.basename($0)} msimpact [options] --author string"

          o.on_tail("-h", "--help", "Show help and examples") {
            print(o)
            print(example)
            exit()
          }
          # o.on("--tabulate","Output tab delimited table (default)") do
          #   options.output = :tabulate
          # end
          o.on("--author query",String,"Search query") do |query|
            options.author = query
          end
          o.on("--link url",String,"MS url") do |url|
            options.link = url
          end
          o.on("--search domain",String,"Search (e.g. bioinformatics)") do |query|
            options.search = query
          end
        end
        opts.parse!(ARGV)
        $stderr.print options

        if options.search
          print '"Name","Organisation","Publications","Citations","URL",""',"\n"
          list_authors(options.search).each do | author |
            print '"',[author[:author],author[:organisation],author[:publications],author[:citations],author[:url]].join('","'),'"',"\n"
          end
        elsif options.link
          print '"Name","Publications","Citations","G-index","H-index","Organization","Subjects"',"\n"
          print '"',author_link(options).join('","'),'"',"\n"
        else
          print '"Name","Publications","Citations","G-index","H-index","Organization","Subjects"',"\n"
          print '"',author_info(options).join('","'),'"',"\n"
        end
      end

      def Parser::list_authors search
        a = Mechanize.new { |agent|
          agent.user_agent_alias = 'Mac Safari'
        }
        list = []
        current = {}

        [2,4].each do | domain |
          (0..5).each do | page |
            $stderr.print "."
            a.get("http://academic.research.microsoft.com/Detail?query=bioinformatics&searchtype=1&SearchDomain=#{domain}&start=#{page*PAGE_SIZE+1}&end=#{(page+1)*PAGE_SIZE}") do | page |      
              page.links.each do | link |
                if link.text =~ /^Profile - /
                  name = $'
                  name = name.split(" (")[0] if name =~ / \(/
                  list << current
                  current = {}
                  current[:author] = name
                  current[:url] = link.href
                elsif link.href =~ /Organization/
                  current[:organisation] = link.text
                elsif link.text =~ /Publications: (\d+)/
                  current[:publications] = $1
                elsif link.text =~ /Citations: (\d+)/
                  current[:citations] = $1
                end
              end
            end
          end
        end
        list
      end

      def Parser::author_link options
        url = options.link
        agent = Mechanize.new
        page = agent.get url
        return parse_author_page(page)
      end

      def Parser::author_info options
        author = options.author
        agent = Mechanize.new
        page = agent.get "http://academic.research.microsoft.com/search.html?query="+author
        listpage = agent.page.link_with(:text => author)
        if listpage
          return parse_author_page(listpage.click)
        else
          return ["Not found"]
        end
      end
     
      def Parser::parse_org_from_author_page page
        page.links.each do | link |
          if link.href =~ /Organization/
            return link.text
          end
          ''
        end
      end

      def Parser::parse_author_page page
        buf = page.body
        buf =~ /meta name="description" content="View ([^']+)'s professional profile. Publications: (\d+) \| Citations: (\d+) \| G-Index: (\d+) \| H-Index: (\d+)\. Interests: ([^"]+)/
     
        author = $1
        publications = $2
        citations = $3
        g_index = $4
        h_index = $5
        subjects = $6

        return [author,publications,citations,g_index,h_index,parse_org_from_author_page(page),subjects]
      end
    end
  end
end
