$stdin.each_line do |l|
    if l[0] != ">"
       l.gsub!( /[\-nN]/, "" ) 
    end
    
    puts l
end