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
  dns_records = {}
  dns_raw.each do |line|
    unless line[0] == "#" or line.strip.empty?
      line = line.split(",")
      if line[0].strip == "A"
        dns_records[line[1].strip] = { :type => "A", :IP_address => line[2].strip }
      else
        dns_records[line[1].strip] = { :type => "CNAME", :alias => line[2].strip }
      end
    end
  end
  dns_records
end

def resolve(dns_records, lookup_chain, domain)
  dns_record = dns_records[domain]
  if dns_record == nil
    puts "Error: record not found for #{domain}"
    exit
  elsif dns_record[:type] == "A"
    lookup_chain.push(dns_record[:IP_address])
  else
    #cycle check
    cycle_domain = lookup_chain.find { |element| element == dns_record[:alias] }
    if cycle_domain != nil
      puts "invalid zone file (it may contain cycles)"
      exit
    end
    lookup_chain.push(dns_record[:alias])
    lookup_chain = resolve(dns_records, lookup_chain, dns_record[:alias])
  end

  lookup_chain
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
