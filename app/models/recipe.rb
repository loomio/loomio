class Recipe < ApplicationRecord
	before_create :update_title

	def update_title
		self.title = dom.title
	end

	def dom
		Nokogiri::HTML::Document.parse(body)
	end

	def discussion_templates
		r = dom.css('table[data-loomio-thread]')
		r.map do |table|
			h = {}
			table.css('tr').each do |tr|
				h[tr.children[0].text] = tr.children[1].text
			end
			h
		end
	end

	def poll_templates
		r = dom.css('table[data-loomio-poll]')
		r.map do |table|
			h = {}
			options_h = {}
			table.css('tr').each do |tr|
				key = tr.children[0].text
				value = tr.children[1].text
				if data = /^option(\d+) (\S+)/.match(key)
					options_h[data[1]] ||= {}
					options_h[data[1]][data[2]]= value
				else
					h[key] = value
				end
			end
			h['options'] = options_h.values
			h
		end
	end
end