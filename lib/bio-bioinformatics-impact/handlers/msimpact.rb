require 'bio-logger'
require 'ostruct'
require 'mechanize'
require 'logger'

module BioBioinformaticsImpact
  module MsImpact
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
        end
        opts.parse!(ARGV)
        $stderr.print options

        author = options.author
        agent = Mechanize.new
        # agent.log = Logger.new "mech.log"
        # agent.user_agent_alias = 'Mac Safari'
        if true
          page = agent.get "http://academic.research.microsoft.com/search.html?query=Lincoln D. Stein"
          authorpage = agent.page.link_with(:text => author).click
          buf = authorpage.body
        else
          buf = File.open("author.txt").read
        end
        # p authorpage
        # puts authorpage.body
        # p buf

        # <meta name="description" content="View Lincoln D. Stein's professional profi
        # le. Publications: 274 | Citations: 10264 | G-Index: 99 | H-Index: 45. Interests:
        #  Molecular Biology, Biochemistry, Genetics & Genealogy" />

        buf =~ /meta name="description" content="View #{author}'s professional profile. Publications: (\d+) \| Citations: (\d+) \| G-Index: (\d+) \| H-Index: (\d+)\. Interests:/
 
        publications = $1
        citations = $2
        g_index = $3
        h_index = $4

        print '"Name","Publications","Citations","G-index","H-index"',"\n"
        print '"',[author,publications,citations,g_index,h_index].join('","'),'"',"\n"

        # page = agent.get "http://academic.research.microsoft.com/Author/28276/lincoln-d-stein"
        # p page
        # search_form = page.form_with :name => "f"
        # p search_form
        # search_form.field_with(:name => "q").value = "Hello"
        # search_results = agent.submit search_form
        # puts search_results.body

      end
    end
  end
end
