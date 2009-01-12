require 'net/http'
require 'rexml/document'
require 'rexml/xpath'


f_pdb = File.open( "pdbids.txt", "w");

pdb_ids = {}

##################################################3
# ec kegg mapping
###################################################

$kegg_ec_name = "/home/b/berger/dipl/ext_stor/kegg/reaction"
$ec_kegg = {}
$ec_kegg_multi = {}
$kegg_ec = {}
#FasterCSV.foreach($kegg_ec_name, {:col_sep => ",", :headers => true}) do |l|
#	$ec_kegg[l["ec"]] = l["rid"];
#end


begin
	rid = nil
	ecl = [];

	nl = -1;
	IO.foreach( $kegg_ec_name ) do |line|
		nl+=1;
		if line =~ /ENTRY\s+(R\d{5})/
			rid = $1;
        elsif line =~ /ENZYME\s+(\d+\.\d+\.\d+\.\d+\s*)+/
			ecl = $1.split(/\s+/);
		elsif line =~ /\/\/\//
			if rid == nil 
				throw "no rid in kegg reaction entry (line #{nl})";
            end
			
			
			
			ecl.each do |ec|
				
				if $ec_kegg_multi[ec] == nil
					$ec_kegg_multi[ec] = [rid]
                else
					$ec_kegg_multi[ec] << rid
				end
				
				
				
				$ec_kegg[ec] = rid;
			end
			
			$kegg_ec[rid] = ecl;
			
			rid = nil;
			ecl = [];
		end
		
		
    end

end




File.open( "catres.csv", "w" ) do |h|
	h.puts( "macieId\tec\tpdbid\tres\tseq\tchain\taa\trole\tgroup\tkegg" );

	Dir["M*.cml.xml"].sort.each do |name|
	
		txt = IO.read( name );
		
		doc = REXML::Document.new(txt);
		
		pdbele = REXML::XPath.first( doc, 'cml/reactionScheme/identifier[@dictRef="macie:primaryPDBCode"]' );
		
		pdbid = pdbele.attributes["value"]; 
		puts( pdbid );
		
		
		#		ecele1 =  REXML::XPath.first( doc, 'reactionScheme/identifier[@dictRef="macie:ecNumber"]/label[@dictRef="macie:ecNumberL1"]' );
		#		ecele2 =  REXML::XPath.first( doc, 'reactionScheme/identifier[@dictRef="macie:ecNumber"]/label[@dictRef="macie:ecNumberL2"]' );
		#		ecele3 =  REXML::XPath.first( doc, 'reactionScheme/identifier[@dictRef="macie:ecNumber"]/label[@dictRef="macie:ecNumberL3"]' );
		#		ecele4 =  REXML::XPath.first( doc, 'reactionScheme/identifier[@dictRef="macie:ecNumber"]/label[@dictRef="macie:ecNumberL4"]' );
		#		
		#		ec1 = ecele1.attributes["value"];
		#		ec2 = ecele2.attributes["value"];
		#		ec3 = ecele3.attributes["value"];
		#		ec4 = ecele4.attributes["value"];
		
		ecele =  REXML::XPath.first( doc, 'cml/reactionScheme/identifier[@dictRef="macie:ecNumber"]' );
		
		ec = ecele.attributes["value"];
		
		
		puts( "name: #{name}" );
		puts( "ec: #{ec}" );
		
		if name =~ /(.+)\.cml/
			macieId = $1;
        end
		
		#doc.elements.each('reactionScheme/metadataList/metadataList/metadata[@dictRef="macie:catalyticResidueList"]') do |ele|
		#		REXML::XPath.each( doc, 'cml/reactionScheme/metadataList/metadataList/metadata[@dictRef="macie:catalyticResidueList"]') do |ele|
		#		#	puts( "found" );   
		#		#	puts( ele.xpath );
		#			#puts( ele.attributes["content"] );
		#			
		#			res = ele.attributes["content"];
		#			
		#			aa = "XXX";
		#			
		#			if( res =~ /(([A-Z][a-z]{2})[0-9]+)([A-Z])/ ) 
		#				puts( "match" );
		#				res = "#{$3}_#{$1}";
		#				puts( res );
		#				aa = $2.upcase;
		#			elsif( res =~ /(([A-Z][a-z]{2})[0-9]+)/ )
		#				puts( "match, no chain. suppose A" );
		#				res = "A_#{$1}"
		#				puts( res );
		#				aa = $2.upcase;
		#			end
		#			
		#			res.upcase!;
		#			
		#			h.puts( "#{macieId},#{ec},#{pdbid},#{res},#{aa}" );
		#			h.flush
		#		end

		#REXML::XPath.each( doc, 'cml/reactionScheme/reaction[@role="macie:overallReaction"]/substanceList/substance[@role="reactant" and @dictRef="macie:sideChain"]') do |ele|

		chain_count = {};
        REXML::XPath.each( doc, 'cml/reactionScheme/reaction[@role="macie:overallReaction"]/substanceList/substance[@dictRef="macie:sideChain" or @dictRef="macie:mainChainAmide" or @dictRef="macie:mainChainCarbonyl"]') do |ele|
			#puts( "reactant: #{ele.attributes["title"].upcase}");
			
			aa = ele.attributes["title"].upcase;

			role = ele.attributes["role"];
			
			fullid = ele.attributes["id"];

			mcsc = ele.attributes["dictRef"];
			
			if mcsc == "macie:sideChain"
				group = "sc"
            else
				group = "mc"
			end
			
			
			res = "_";
			seq = "_";
			
			
			
			if fullid =~ /(\d\w{3})((\w{3})(\d+))(\w)(\d+)/
				chain = $5;
				
				res = $2
				seq = $4;
				if( chain_count[chain] == nil )
					chain_count[chain] = 1;
                else
					chain_count[chain] += 1;
				end
            end
			
			
			#			if ele.attributes["id"] =~ /\w{4}(\w{3}\d+)/
			#				res = $1;
			#				
			#            end

			rids = $ec_kegg_multi[ec];
			
			rids = ["none"] if rids == nil
			
			ridj = "#{rids.join("|")}";
			
			h.puts( "#{macieId}\t#{ec}\t#{pdbid}\t#{res}\t#{seq}\t#{chain}\t#{aa}\t#{role}\t#{group}\t#{ridj}" );
			
			
		
        end
		
		if pdb_ids[pdbid] != nil
			throw "duplicate pdbid: #{pdbid}";
		end
		pdb_ids[pdbid] = 1;
		chain_count.each_pair do |chain,count|
			#puts( "#{chain}: #{count}")
			f_pdb.puts( "#{pdbid}#{chain}" );
        end
	end
end


f_pdb.close();

File.open( "pdbids_raw.txt", "w" ) do |h|
	pdb_ids.each do |k,v|
		h.puts( k );
    end
end
