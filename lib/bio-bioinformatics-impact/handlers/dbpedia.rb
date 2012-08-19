require 'bio-logger'
require 'ostruct'
require 'logger'
require 'four_store/store'

module BioBioinformaticsImpact
  module DbPedia
    module Parser
      include Bio::Log

      PREFIX = """
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX p: <http://dbpedia.org/property/>
PREFIX dbpedia: <http://dbpedia.org/resource/>
PREFIX category: <http://dbpedia.org/resource/Category:>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX geo: <http://www.georss.org/georss/>
"""

      module Person
        def Person::get_info store,id
          query = """
            select ?name,?abstract,?comment,?almamater where 
            {
            dbpedia:#{id}   rdfs:label ?name .
            OPTIONAL { dbpedia:#{id} rdfs:comment ?comment ; 
                                     dbpedia-owl:abstract ?abstract ;
                                     dbpprop:almaMater ?almamater . }
            }
            limit 10
            """
          response = store.select(PREFIX+query)
          raise "Problem with size of #{response}" if response.size != 1
          response[0]
        end
        def Person::get_workplaces store,id
          query = """
            select ?name,?workplace where
            {
            dbpedia:#{id}   rdfs:label ?name .
            OPTIONAL { dbpedia:#{id} dbpprop:workplaces ?workplace . }
            }
            limit 10
            """
          response = store.select(PREFIX+query)
          response.map { |item| item['workplace'] }
        end
        def Person::get_awards store,id
          query = """
            select ?name,?award where
            {
            dbpedia:#{id}   rdfs:label ?name .
            OPTIONAL { dbpedia:#{id} dbpprop:awards ?award . }
            }
            limit 10
            """
          response = store.select(PREFIX+query)
          response.map { |item| item['award'] }
        end
      end

      def Parser::handler
        log = LoggerPlus.new 'dbpedia'
        options = OpenStruct.new()
        # options.author_layout = "surname+', '+initials.join('. ')+'.'"
        # options.authors_join = ", "
        
        example = """
    Examples:

        """
        opts = OptionParser.new() do |o|
          o.banner = "Usage: #{File.basename($0)} dbpedia [options]"

          o.on_tail("-h", "--help", "Show help and examples") {
            print(o)
            print(example)
            exit()
          }
          # o.on("--tabulate","Output tab delimited table (default)") do
          #   options.output = :tabulate
          # end
          o.on("--person query",String,"Search query") do |query|
            options.person = query
          end
        end
        opts.parse!(ARGV)
        $stderr.print options

        store = FourStore::Store.new 'http://dbpedia.org/sparql/'
        info = Person::get_info(store,options.person)
        workplaces = Person::get_workplaces(store,options.person)
        awards = Person::get_awards(store,options.person)
        print '"name","abstract","almamater","workplaces","awards","comment"',"\n"
        print '"',[info["name"],info["abstract"],info["almamater"],workplaces.join(", "),awards.join(", "),info["comment"]].join("\",\""),"\"\n"
      end
    end
  end
end
