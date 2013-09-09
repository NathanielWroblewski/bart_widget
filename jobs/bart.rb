require 'net/http'
require 'open-uri'
require 'xmlsimple'

stations = {
  '12th' => '12th St. Oakland',
  '16th' => '16th St. Mission',
  '19th' => '19th St. Oakland',
  '24th' => '24th St. Mission',
  'ashb' => 'Ashby',
  'balb' => 'Balboa Park',
  'bayf' => 'Bay Fair',
  'cast' => 'Castro Valley',
  'civc' => 'Civic Center',
  'cols' => 'Coliseum',
  'colm' => 'Colma',
  'daly' => 'Daly City',
  'dbrk' => 'Downtown Berkeley',
  'dubl' => 'Dublin/Pleasanton',
  'deln' => 'Cerrito del Norte',
  'plza' => 'El Cerrito Plaza',
  'embr' => 'Embarcadero',
  'frmt' => 'Fremont',
  'ftvl' => 'Fruitvale',
  'glen' => 'Glen Park',
  'hayw' => 'Hayward',
  'lafy' => 'Lafayette',
  'lake' => 'Lake Merritt',
  'mcar' => 'MacArthur',
  'mlbr' => 'Millbrae',
  'mont' => 'Montgomery',
  'nbrk' => 'North Berkeley',
  'ncon' => 'North Concord',
  'orin' => 'Orinda',
  'pitt' => 'Pittsburg/Bay Point',
  'phil' => 'Pleasant Hill',
  'powl' => 'Powell St.',
  'rich' => 'Richmond',
  'rock' => 'Rockridge',
  'sbrn' => 'San Bruno',
  'sfia' => 'SFO',
  'sanl' => 'San Leandro',
  'shay' => 'South Hayward',
  'ssan' => 'South San Francisco',
  'ucty' => 'Union City',
  'wcrk' => 'Walnut Creek',
  'wdub' => 'West Dublin',
  'woak' => 'West Oakland'
}

SCHEDULER.every '2m', first_in: 0 do

  origin    = '' # <-- Enter your station's key from the stations hash above
  direction = '' # <-- Enter 'N' for northbound or 'S' for southbound

  uri = URI.parse(
    'http://api.bart.gov/api/etd.aspx?cmd=etd&key=MW9S-E7SL-26DU-VV8V&orig=' +
    "#{origin.upcase}&dir=#{direction.upcase}"
  )
  response = Net::HTTP.get(uri)
  page     = XmlSimple.xml_in(response)
  estimate = page['station'][0]['etd'][0]['estimate']
  arrival  = estimate[0]['minutes'][0]

  first_train_in = ':' + (arrival.to_i < 10 ? '0' : '') + arrival
  next_train_in  = estimate[1]['minutes'][0] + ' min'

  direction.upcase == 'N' ? bound = 'NORTHBOUND' : bound = 'SOUTHBOUND'

  send_event('bart', {
    station: stations[origin].upcase,
    bound:   bound,
    first:   first_train_in,
    second:  next_train_in
  })
end
