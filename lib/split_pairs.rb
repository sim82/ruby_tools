

prefix = ARGV[0] || ""
    

acc = nil
i = 0;

$stdin.each_line do |l|
    if acc != nil
        
        is = i.to_s
        is = ("0" * (2 - [0, is.size].max)) + is;
        File.open( prefix + "_" + is, "w" ) do |f|
            f.puts(acc)
            f.puts(l)
        end
        acc = nil
        i += 1;
    else
        acc = l
    end
end
