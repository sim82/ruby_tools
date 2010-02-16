bestmap = {}

def start_with?( me, other ) 
   if me.length >= other.length 
       return me[0..other.length-1] == other;
   else
       return false;
   end
end

$stdin.each_line do |l|
    ls = l.split
    
    me = ls[0];
    other = ls[1];
    
    next if start_with?( me, other )
    
#     puts( "start with #{me} #{other} #{start_with?( me, other )}" );
    
    score = ls[11].to_f;
    
    if( bestmap[me] == nil ) 
        bestmap[me] = [other, score]
    else
        (op, sp) = bestmap[me];
        
        if( score > sp )
            bestmap[me] = [other, score]
        end
    end
end


bestmap.keys.sort.each do |me|
    (other, score) = bestmap[me];
    
    puts "#{me} #{other}"
end



	