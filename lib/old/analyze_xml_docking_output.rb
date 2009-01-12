require 'rexml/document'
require 'rexml/xpath'


name = ARGV[0];

txt = IO.read( name );
doc = REXML::Document.new( txt );
#doc.write($stdout, 0);

REXML::XPath.each( doc, 'propka/aaResidue/shiftArray[@type="coulomb"]/shift[@resClass="LigandResidue"]/../..' ) do |e|
	puts("match:");
	e.write();
	puts();
end



