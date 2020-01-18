def get_command_line_argument
    if ARGV.empty?
      puts "Usage: ruby lookup.rb <domain>"
      exit
    end
    ARGV.first
  end
  
 
  domain = get_command_line_argument

  dns_raw = File.readlines("zone")
 
def parse_dns(dn)
    ar=[]
    dn.each do |line|
       if line[0]=="A" || line[0]=="C"
            temp=line.split(",")
            temp=temp.map {|ele|  ele.strip}
            ar.push(temp) 
       end
    end
    ar
end

def resolve(dns,look,dom)
    ans=dns.filter {|ele| ele[1]==dom && ele[0]=="A"}
    if ans.length==0
        ans=dns.filter {|ele| ele[1]==dom}
        if ans.length==0
            puts "Error: record not found for #{dom}"
            exit
        else
            dom=ans[0][2]
            #cycle checking
            cyc=look.find {|e| e==dom}
            if cyc!=nil
                puts "No record found ..Cylce in CNames"
                exit
            end
            look.push(ans[0][2])
            look=resolve(dns,look,dom)
        end
    else
        look.push(ans[0][2])
    end
    look
end

  dns_records = parse_dns(dns_raw)
  lookup_chain = [domain]
  lookup_chain = resolve(dns_records, lookup_chain, domain)
  puts lookup_chain.join(" => ")
