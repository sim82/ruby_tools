require 'csv';

ec_to_rid = {}

first = true;
CSV.open( "/home/b/berger/dipl/ext_stor/kegg/rid.csv", "r" ) do |l|
#	if first 
#		first = false;	
#		next;
#    end
	
	ec = l[1];
	rid = l[0];
	
	cur = ec_to_rid[ec];
	
	if( cur == nil )
		ec_to_rid[ec] = [rid];
	else 
		ec_to_rid[ec] = cur << rid;
	end
	
#	puts( "ec: #{ec} #{rid}");
end


its_files = {}

Dir["/mnt/data/A/BIO-A/apostola/ch/cheminfo/admin/its_scpdb/all_hfix/chiral_its/*_a.mol2"].each do |name|
	
	
	if( name =~ /(R\d{5})_/)
		rid = $1;
		
		l = its_files[rid];
		if l == nil 
			l = [];
			its_files[rid] = l;
        end
		
		l << name;
    end
	
	
end

its_dock_data = {}

CSV.open( "/mnt/data/C/BIO-C/marialke/results/ITS_debug/out.csv", "r", fs="\t" ) do |l|
	its_dock_data[l[0]] = l;
end




#CSV.
	
#throw "exit";

$name = ARGV[0]

pdbid_ec3_map = {};
id_ec3_map = {};


first = true;
CSV.open($name, "r") do |l|  
	#puts( l[2]);

	if first
		first = false;
		next;
    end
	
	
	ec = l[2];
	id = l[0];
	
	
	pdbid = nil;
	ec3 = nil;
	if( id =~ /mol2\_([\w\d]{4})\_/ ) 
		pdbid = $1;
		#	puts( "pdb: #{pdbid}");
    end
	
	if( ec =~ /((\d+)\.(\d+)\.(\d+))\.(\d+)/)
		ec3 = $1;
	end
	
	throw "could not find pdbid or l3 ec (#{id} #{ec})" if pdbid == nil or ec3 == nil;
	
	pdbid_ec3_map[pdbid] = ec3;
	id_ec3_map[id] = ec3;
end



puts( "id\ttem\tprot\tits");

n = 0;
n1 = 0;
id_ec3_map.each_pair do |id, ec3|


#	puts( "ec l3: #{ec3}" );
	n1+=1;
	IO.foreach( "l3/#{ec3}") do |l|
		l.strip!;
		
		
		
		
		
		
		l_dock = its_dock_data[id];
		
		dock_tem = l_dock[1];
		dock_prot = l_dock[3];
		
		rid_list = ec_to_rid[l];
		
		next if rid_list == nil;

#		if( l == "4.3.2.2")
#			puts( "rid: #{rid_list}");
#		end
		
		rid_list.each do |rid|
			


		#	puts("rid: #{rid}")
			its_list = its_files[rid];
			
			next if its_list == nil;
			
			
			its_list.each do |name|
				its_name = nil;
				if( name =~ /\/(R\d{5}.+)$/)
					its_name = $1;
				end
				
				puts( "#{id}_#{its_name}\t#{dock_tem}\t#{dock_prot}\t#{name}");		
            end
			
			
			n+=1;
        end
		
	end
    
end


#puts( "n: #{n} #{n1}")