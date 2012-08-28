require 'bio-logger'
require 'ostruct'
require 'mechanize'
require 'logger'

# http://code.google.com/p/citations-gadget/

module BioBioinformaticsImpact
  module Scholar

    module Parser
      include Bio::Log

      def Parser::handler
        log = LoggerPlus.new 'scholar'
        options = OpenStruct.new()
        
        example = """
    Examples:

        """
        opts = OptionParser.new() do |o|
          o.banner = "Usage: #{File.basename($0)} scholar [options] --author string"

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
        end
        opts.parse!(ARGV)
        $stderr.print options

        print '"Name","Publications","Citations","H-index"',"\n"
        print '"',author_info(options).join('","'),'"',"\n"
      end

      def Parser::author_info options
        author = options.author
        agent = Mechanize.new
        page = agent.get "http://code.google.com/p/citations-gadget/"
        # listpage = agent.page.link_with(:text => author)
        # if listpage
        #   return parse_author_page(listpage.click)
        # else
        #   return ["Not found"]
        # end
        p page
      end
     
      def Parser::parse_org_from_author_page page
        page.links.each do | link |
          if link.href =~ /Organization/
            return link.text
          end
        end
        ''
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
