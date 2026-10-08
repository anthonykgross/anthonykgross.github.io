#!/usr/bin/env ruby
# Checks the machine-readable views of a production build in _site/:
# JSON-LD, lang/canonical/hreflang, robots.txt, sitemap.xml, Markdown views,
# the visible CV content, and what must never be published.
#
# Run after a production build:  make check   (CI runs it before deploying)
# Stdlib only, so it runs as-is in the jekyll/jekyll and jekyll/builder images.
require "json"
require "yaml"

# The jekyll Docker images swallow stderr: report a crash on stdout so CI shows why it failed.
at_exit do
  e = $!
  puts "check-machine-views: crashed: #{e.class}: #{e.message} (#{e.backtrace&.first})" if e && !e.is_a?(SystemExit)
end

ROOT = File.expand_path("..", __dir__)
SITE = File.join(ROOT, "_site")

# CI replaces _config.yml with _config_prod.yml; locally the prod file still exists.
config_file = %w[_config_prod.yml _config.yml].map { |f| File.join(ROOT, f) }.find { |f| File.exist?(f) }
BASE = YAML.load_file(config_file).fetch("url").chomp("/")

PAGES = [
  { file: "index.html",          url: "/",               lang: "fr-FR", variant: "hands-off", data: "cv_hands_off_fr", md: "cv/hands-off.md" },
  { file: "cv/hands-on.html",    url: "/cv/hands-on",    lang: "fr-FR", variant: "hands-on",  data: "cv_hands_on_fr",  md: "cv/hands-on.md" },
  { file: "en/cv.html",          url: "/en/cv",          lang: "en-US", variant: "hands-off", data: "cv_hands_off_en", md: "en/cv/hands-off.md" },
  { file: "en/cv/hands-on.html", url: "/en/cv/hands-on", lang: "en-US", variant: "hands-on",  data: "cv_hands_on_en",  md: "en/cv/hands-on.md" },
].freeze

$failures = []
def check(ok, message)
  $failures << message unless ok
end

def read(rel)
  path = File.join(SITE, rel)
  unless File.exist?(path)
    $failures << "missing file: _site/#{rel}"
    return nil
  end
  File.read(path, encoding: "UTF-8")
end

def yaml_data(name)
  YAML.load_file(File.join(ROOT, "_data", "#{name}.yml"))
end

person = yaml_data("person")
city = person["location"]["city"].to_s.strip
check(!city.empty?, "_data/person.yml: location.city is empty")
check(BASE.start_with?("https://") && !BASE.include?("localhost"), "site url is not a production URL: #{BASE}")

# Values that must never reach a machine-readable view.
private_values = PAGES.flat_map { |p| yaml_data(p[:data])["profile"].values_at("status", "interests") }.compact.uniq

person_nodes = []
PAGES.each do |p|
  html = read(p[:file]) or next
  cv = yaml_data(p[:data])
  where = "_site/#{p[:file]}"
  short = p[:lang][0, 2]
  pair = PAGES.select { |o| o[:variant] == p[:variant] }

  # lang, locale, title, description, canonical
  check(html.include?(%(<html lang="#{p[:lang]}">)), "#{where}: <html lang> is not #{p[:lang]}")
  check(html.include?(%(<meta property="og:locale" content="#{p[:lang].tr('-', '_')}"/>)), "#{where}: og:locale is not #{p[:lang].tr('-', '_')}")
  check(html =~ %r{<title>#{Regexp.escape(cv['title'])} - }, "#{where}: <title> does not start with the facet title #{cv['title']}")
  check(html =~ /<meta name="description" content="[^"]{20,}">/, "#{where}: missing meta description")
  check(html.include?(%(<link rel="canonical" href="#{BASE}#{p[:url]}">)), "#{where}: wrong or missing canonical")

  # hreflang: both languages of the same variant, plus x-default on the FR page
  pair.each do |o|
    check(html.include?(%(<link rel="alternate" hreflang="#{o[:lang][0, 2]}" href="#{BASE}#{o[:url]}">)), "#{where}: missing hreflang #{o[:lang][0, 2]} -> #{o[:url]}")
  end
  fr = pair.find { |o| o[:lang] == "fr-FR" }
  check(html.include?(%(<link rel="alternate" hreflang="x-default" href="#{BASE}#{fr[:url]}">)), "#{where}: x-default is not #{fr[:url]}")
  check(html.scan(/hreflang=/).size == 3, "#{where}: expected exactly 3 hreflang links")
  check(html.include?(%(<link rel="alternate" type="text/markdown" href="#{BASE}/#{p[:md]}">)), "#{where}: missing Markdown alternate link")

  # Value: protects=og:locale:alternate loop in _layouts/default.html (alt.cv_lang != page.cv_lang); fails_when=the alternate is dropped, duplicated, points at the page's own locale, or loses the '-'->'_' replace; why_new=no existing check reads og:locale:alternate; seam=none
  other_locale = pair.find { |o| o[:lang] != p[:lang] }[:lang].tr("-", "_")
  alternates = html.scan(%r{<meta property="og:locale:alternate" content="([^"]*)"/>}).flatten
  check(alternates == [other_locale], "#{where}: og:locale:alternate should be exactly [#{other_locale}], got #{alternates.inspect}")

  # JSON-LD: exactly one block, valid JSON, no localhost, no private values
  blocks = html.scan(%r{<script type="application/ld\+json">\n(.*?)\n</script>}m).flatten
  check(blocks.size == 1, "#{where}: expected exactly 1 JSON-LD block, found #{blocks.size}")
  if blocks.size == 1
    begin
      graph = JSON.parse(blocks.first).fetch("@graph")
      node = graph.find { |n| n["@type"] == "Person" }
      profile = graph.find { |n| n["@type"] == "ProfilePage" }
      check(node && node["@id"] == "#{BASE}/#person", "#{where}: Person node missing or wrong @id")
      check(profile && profile["url"] == "#{BASE}#{p[:url]}" && profile["inLanguage"] == p[:lang], "#{where}: ProfilePage url/inLanguage wrong")
      check(profile && profile.dig("about", "@id").to_s.end_with?(p[:variant] == "hands-off" ? "#head-of-engineering" : "#principal-engineer"), "#{where}: ProfilePage is not about its facet")
      person_nodes << node
    rescue JSON::ParserError, KeyError => e
      check(false, "#{where}: invalid JSON-LD (#{e.class}: #{e.message[0, 120]})")
    end
    check(!blocks.first.include?("localhost"), "#{where}: JSON-LD contains localhost")
    private_values.each { |v| check(!blocks.first.include?(v), "#{where}: JSON-LD exposes a private profile value") }
  end

  # Visible CV must not regress (eng review D4)
  # The full line, with its closing tag, so a blank city (", France") cannot pass.
  check(html.include?(">#{city}, #{person['location']['country'][short]}</div>"), "#{where}: visible location line is missing")
  articles = html.scan(/<article\b/).size
  check(articles == cv["experiences"].size, "#{where}: #{articles} experience blocks, YAML has #{cv['experiences'].size}")

  # Markdown view
  md = read(p[:md]) or next
  check(md.start_with?("# #{person['name']} — #{cv['title']}"), "_site/#{p[:md]}: unexpected heading")
  check(md !~ %r{</?[a-z][^>]*>}i, "_site/#{p[:md]}: contains HTML tags")
  check(md.include?("#{BASE}#{p[:url]}"), "_site/#{p[:md]}: missing link to its HTML page")
  cv["experiences"].each { |e| check(md.include?(e["position"].to_s), "_site/#{p[:md]}: missing experience #{e['position']}") }
  private_values.each { |v| check(!md.include?(v), "_site/#{p[:md]}: exposes a private profile value") }

  # Value: protects=the "other facet" link in _layouts/cv-markdown.html (other_pages filtered by cv_lang, p.variant != page.variant); fails_when=the link points at the wrong language, the same facet, or disappears; why_new=existing checks only verify the link back to the HTML page; seam=none
  sibling = PAGES.find { |o| o[:lang] == p[:lang] && o[:variant] != p[:variant] }
  check(md.include?("#{BASE}/#{sibling[:md]}") && md.scan(%r{#{Regexp.escape(BASE)}/\S+\.md}).uniq == ["#{BASE}/#{sibling[:md]}"], "_site/#{p[:md]}: other-facet link must point only at #{sibling[:md]}")

  # Value: protects=the `if cv.management_skills` branch and FR/EN label switch in _layouts/cv-markdown.html, plus the new profile.languages entries; fails_when=management skills vanish from hands-off, leak into hands-on, labels render in the wrong language, or a spoken language is dropped; why_new=only the H1 and experience positions were checked; seam=none
  mgmt_label = short == "fr" ? "## Compétences managériales" : "## Management skills"
  mgmt = cv["management_skills"] || []
  check(md.include?(mgmt_label) == !mgmt.empty?, "_site/#{p[:md]}: management skills section present=#{md.include?(mgmt_label)}, YAML has #{mgmt.size} categories")
  mgmt.each { |c| check(md.include?("### #{c['category']}"), "_site/#{p[:md]}: missing management category #{c['category']}") }
  cv["profile"]["languages"].each { |l| check(md.include?("- #{l}"), "_site/#{p[:md]}: missing spoken language #{l}") }
  # Spoken languages live in two places: person.yml (JSON-LD) and each CV YAML (visible + .md).
  check(cv["profile"]["languages"].size == person["languages"].size, "#{p[:data]}.yml lists #{cv['profile']['languages'].size} spoken languages, _data/person.yml lists #{person['languages'].size}")
end

check(person_nodes.size == PAGES.size && person_nodes.uniq.size == 1, "Person node differs between pages (it must be identical on all 4)")

# Value: protects=the Person node fields built in _includes/jsonld.html (sameAs loop over site.socials, knowsLanguage, address, hasOccupation @ids that ProfilePage.about references); fails_when=a social link, language or address field goes missing, or an Occupation @id no longer matches the ProfilePage.about target; why_new=existing checks only compare Person nodes with each other and check its @id; seam=none
if (node = person_nodes.first)
  socials = YAML.load_file(config_file).fetch("socials").values.map { |v| v["url"] }
  check(node["sameAs"] == socials, "JSON-LD Person.sameAs #{node['sameAs'].inspect} != config socials #{socials.inspect}")
  check(node["knowsLanguage"] == person["languages"], "JSON-LD Person.knowsLanguage != _data/person.yml languages")
  check(node.dig("address", "addressLocality") == person["location"]["city"] && node.dig("address", "addressCountry") == person["location"]["country_code"], "JSON-LD Person.address does not match _data/person.yml")
  check(node["image"] == "#{BASE}#{person['image']}" && File.exist?(File.join(SITE, person["image"])), "JSON-LD Person.image #{node['image'].inspect} is wrong or not published")
  occupation_ids = Array(node["hasOccupation"]).map { |o| o["@id"] }
  check(occupation_ids == ["#{BASE}/#head-of-engineering", "#{BASE}/#principal-engineer"], "JSON-LD Person.hasOccupation @ids are #{occupation_ids.inspect}")
end

# Value: protects=the CLAUDE.md rule that CI replaces _config.yml with _config_prod.yml, so plugins/exclude/defaults must be in both; fails_when=a plugin (e.g. jekyll-sitemap), exclude entry (bin, docs, TODOS.md) or the assets sitemap default is added to only one config; why_new=make check builds only with _config_prod.yml, so dev-only drift is invisible; seam=none
dev_config, prod_config = %w[_config.yml _config_prod.yml].map { |f| File.join(ROOT, f) }
if File.exist?(dev_config) && File.exist?(prod_config)
  dev, prod = [dev_config, prod_config].map { |f| YAML.load_file(f) }
  %w[plugins defaults].each { |k| check(dev[k] == prod[k], "_config.yml and _config_prod.yml differ on #{k}") }
  check((dev["exclude"] - [".idea"]).sort == (prod["exclude"] - [".idea"]).sort, "_config.yml and _config_prod.yml differ on exclude")
end

# robots.txt: training bots blocked, everyone else allowed
robots = read("robots.txt")
if robots
  groups = robots.split(/\n\s*\n/).map { |g| g.lines.map(&:strip).reject { |l| l.empty? || l.start_with?("#") } }.reject(&:empty?)
  training = groups.find { |g| g.include?("User-agent: GPTBot") }
  star = groups.find { |g| g.include?("User-agent: *") }
  %w[GPTBot ClaudeBot CCBot Google-Extended Applebot-Extended meta-externalagent].each do |bot|
    check(training&.include?("User-agent: #{bot}"), "robots.txt: #{bot} is not in the blocked group")
  end
  check(training&.include?("Disallow: /"), "robots.txt: training group does not Disallow: /")
  check(star && !star.include?("Disallow: /"), "robots.txt: the * group must not Disallow: /")
  check(robots.include?("Sitemap: #{BASE}/sitemap.xml"), "robots.txt: missing Sitemap line")
end

# sitemap.xml: exactly the 4 canonical pages
sitemap = read("sitemap.xml")
if sitemap
  locs = sitemap.scan(%r{<loc>(.*?)</loc>}).flatten.sort
  expected = PAGES.map { |p| "#{BASE}#{p[:url]}" }.sort
  check(locs == expected, "sitemap.xml: expected #{expected.inspect}, got #{locs.inspect}")
end

llms = read("llms.txt")
if llms
  PAGES.each do |p|
    check(llms.include?("(#{BASE}/#{p[:md]})"), "llms.txt: missing Markdown link #{p[:md]}")
    check(llms.include?("(#{BASE}#{p[:url]})"), "llms.txt: missing HTML link #{p[:url]}")
  end
  check(!llms.include?("localhost"), "llms.txt: contains localhost")
  private_values.each { |v| check(!llms.include?(v), "llms.txt: exposes a private profile value") }
end

# Never published (eng review D3)
%w[bin docs TODOS.md].each { |rel| check(!File.exist?(File.join(SITE, rel)), "_site/#{rel} must not be published") }
Dir.glob(File.join(SITE, "assets", "images", "*.{pdf,csv}")).each { |f| check(false, "#{f.sub(ROOT + '/', '')} must not be published") }

if $failures.empty?
  puts "check-machine-views: OK (#{PAGES.size} pages, #{BASE})"
else
  # stdout, not stderr: the jekyll Docker images swallow stderr, and CI must show why it failed.
  puts "check-machine-views: #{$failures.size} failure(s)"
  $failures.each { |f| puts "  - #{f}" }
  exit 1
end
