def get_command_line_argument
    if ARGV.empty?
      puts "Usage: ruby lookup.rb <domain>"
      exit
    end
    ARGV.first
  end
  
 
  domain = get_command_line_argument

  dns_raw = File.readlines("zone")
 
def parse_dns(dns_raw)
    dns_records=dns_raw.filter {|record| record[0]!="#" and !record.strip.empty?}
    dns_records=dns_records.map {|record| record.split(",")}
    dns_records.each do |record|
        record=record.map {|element| element.strip}
    end
       # In each record of dns_records
          #   record[0]=type of record
          #   record[1]=old domain name
          #   record[2]=new domain name or IP address

    dns_records
end

def resolve(dns_records,lookup_chain,domain)
    #checking domain is present in A records or not
    lookup_result=dns_records.find {|record| record[1]==domain && record[0]=="A"}
    #if domain not present in A records
    if lookup_result==nil
        #checking domain is present in CNAME records
        lookup_result=dns_records.find {|record| record[1]==domain && record[0]=="CNAME"}
        #if domain not present in CNAME records
        if lookup_result==nil
            puts "Error: record not found for #{domain}"
            exit
        else
            domain=lookup_result[2]
            #cycle checking
            cycle_domain=lookup_chain.find {|domain_name| domain_name==domain}
            #if current domain already present in lookup chain
            if cycle_domain!=nil
                puts "Zone data is invalid (it may contain cycles)."
                exit
            end
            #push the new NAME of domain and search
            lookup_chain.push(lookup_result[2])
            lookup_chain=resolve(dns_records,lookup_chain,domain)
        end
    else
        #push IP address 
        lookup_chain.push(lookup_result[2])
    end
    lookup_chain
end

  dns_records = parse_dns(dns_raw)
  lookup_chain = [domain]
  lookup_chain = resolve(dns_records, lookup_chain, domain)
  puts lookup_chain.join(" => ")
