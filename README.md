Dashing BART Widget
=
Description
-

A [Dashing](http://shopify.github.com/dashing) widget to display your [BART](http://en.wikipedia.org/wiki/Bay_Area_Rapid_Transit)'s next arrival time using real-time BART data from [The Real BART API](http://www.bart.gov/schedules/developers/api.aspx).

Preview
-
![Screen Shot](http://i.imgur.com/WU6z6w2.png)

Useage
-
To use this widget, copy `bart.coffee`, `bart.html`, and `bart.scss` into the `/widgets/bart` directory of your Dashing app. This directory does not exist in new Dashing apps, so you may have to create it. Copy the `bart.rb` file into your `/jobs` folder, and include the XMLSimple gem in your `Gemfile`. Edit the `bart.rb` file to include your departure station code and direction. Your departure station code can be found by perusing the stations hash included in `bart.rb`. For example, I may enter `phil` for Pleasant Hill and `S` for Southbound where prompted in the `bart.rb` file.

To include the widget in a dashboard, add the following to your dashboard layout file:

#####dashboards/sample.erb

```HTML+ERB
...
  <li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
    <div data-id="bart" data-view="Bart"></div>
  </li>
...
```

Requirements
-
* The [XMLSimple gem](http://rubygems.org/gems/xml-simple)
* Your BART station code (see Useage)
* The direction you're heading (Northbound or Southbound)

Code
-
#####widgets/bart/bart.coffee

```coffee

class Dashing.Bart extends Dashing.Widget

```

#####widgets/bart/bart.html

```HTML
<p class="station" data-bind="station | raw"></p>
<p class="bound" data-bind="bound | raw"></p>
<h1 class="current" data-bind="first | raw"></h1>
<p class="more-info"><span class="next">Next in <span class="next" data-bind="second | raw"></span></span></p>
<p class="updated-at more-info" data-bind="updatedAtMessage"></p>
```

#####widgets/bart/bart.scss

```SCSS
$background-color:  #dc5945;
$title-color:       rgba(255, 255, 255, 0.7);
$moreinfo-color:    rgba(255, 255, 255, 0.3);

.widget-bart {
  background-color: $background-color;
  .station {
    color: $title-color;
    font-size: 30px;
    font-weight: 400;
  }
  .bound {
    color: $moreinfo-color;
  }
  .current {
    font-size: 76px;
    font-weight: 700;
  }
  .next {
    color: $title-color;
  }
  .more-info {
    color: $moreinfo-color;
  }
}
```

#####jobs/bart.rb

```rb
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

```
