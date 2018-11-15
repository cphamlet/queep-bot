# ENUMS          
# This is where the enum-like objects
# are defined

itemTypes = 
	abbrev	: 'abbreviation'
	word	: 'word'

itemIssues =
	multipleAbbrevs	: 'multiple abbreviations'
	abbrevAndWord	: 'abbreviation and word'

# END ENUMS



# BEGIN item issue functions
# this group of functions looks at an item
# and returns true if it has a particular error
# and false otherwise, optionally also returns some item details

str_to_char_dict = () ->
	return arguments

multiple_abbrevs = (item_to_check, item) ->
	if item == item_to_check
		# this is the one we're checking!
		return false
	if item['hash'] == item_to_check['hash'] and\
		item['word'] != item_to_check['word'] and\
		item['type'] == itemTypes.abbrev and\
		item_to_check['type'] == itemTypes.abbrev
		return true
	return false

abbrev_and_word = (item_to_check, item) ->
	if item == item_to_check
		# this is the one we're checking!
		return false
	if item['hash'] == item_to_check['hash'] and item['word'] != item_to_check['word'] and
		(
			(item['type'] == itemTypes.abbrev and item_to_check['type'] == itemTypes.word) or
			(item['type'] == itemTypes.word and item_to_check['type'] == itemTypes.abbrev)
		)
		return true
	return false

# END item issue functions

tag_issue = (item) ->
	if itemIssues.multipleAbbrevs in item['issues']
		return '<span class = "dupe">'+item['word']+'</span>'
	else if itemIssues.abbrevAndWord in item['issues']
		return '<span class = "acro_pair">'+item['word']+'</span>'
	else if item['issues'].length == 0 and item['type'] == itemTypes.word
		return '<span class = "just_word">'+item['word']+'</span>'

	return item['word']


highlight_line = (line, items, line_num) ->
	# "spread" the line
	# basically converts it to a char array
	line_dict = str_to_char_dict(...line)
	
	for item in items
		if item['line'] == line_num
			for i in [item['loc']...item['loc']+item['word'].length]
				delete line_dict[i]
			line_dict[item['loc']] = item

	highlighted_line = ''

	for key in Object.keys(line_dict)
		elem = line_dict[key]

		if typeof elem == 'string'
			highlighted_line += elem
		else
			highlighted_line += tag_issue(elem)

		console.log highlighted_line
	return highlighted_line


highlight_issues = (text, items) ->
	console.log(text)
	lines = text.split('\n')
	highlighted_text = ''

	for i in [0...lines.length]
		highlighted_text += highlight_line(lines[i],items,i) + '\n'

	return highlighted_text


# finds any problems that items may have
# which may need to be pointed out
find_item_issues = (items) ->
	for item_to_check in items
		item_to_check['issues'] = []

		for other_item in items
			if item_to_check == other_item
				continue

			if multiple_abbrevs(item_to_check,other_item)
				item_to_check['issues'].push(itemIssues.multipleAbbrevs)

			if abbrev_and_word(item_to_check,other_item)
				if itemIssues.abbrevAndWord not in item_to_check['issues']
					item_to_check['issues'].push(itemIssues.abbrevAndWord)

	return items

is_alphanumeric = (char) ->
	code = char.charCodeAt(0)

	if !(code > 47 && code < 58) and !(code > 64 && code < 91) && !(code > 96 && code < 123)
		return false

	return true

# find just the items in one line
find_items_in_line = (line, max_len, items, line_num) ->
	# our max len can't be longer than the actual line is
	max_len = Math.min(max_len,line.length)

	# an empty dictionary to store our items
	found = []
	# cut every possible slice
	for line_loc in [0...line.length]

		max_len = Math.min(max_len,line.length-line_loc)
		for i in [max_len...0]
			word = line.slice(line_loc,line_loc+i)
			if items[word] and (line_loc == 0 or !is_alphanumeric(line.slice(line_loc-1,line_loc))) and (line_loc+i == line.length or !is_alphanumeric(line.slice(line_loc+i,line_loc+i+1)))
				found.push({
					'loc':line_loc
					'word':word
					'line':line_num
					'dict':items[word]['dict']
					'type':items[word]['type']
					'hash':items[word]['hash']
					})
	return found

# find all items of interest in the text
find_items = (text, items) ->
	found = []
	# get individual lines
	lines = text.split('\n')

	# TODO: change this to the max item length, not line length
	# the max length of an item (is what it should be)
	max_len = 10

	# iterate through all the lines
	for i in [0...lines.length]
		found = found.concat(find_items_in_line(lines[i], max_len, items, i))

	return found

queep= ->
	text = $('#output').html()
	found = find_items(text,
		{
			'training':{
				'dict':{
					'abbrevs':['trng'],'words':['training']
				},
				'type':itemTypes.word,
				'hash':'asdfbeqr'
			},
			'trng':{
				'dict':{
					'abbrevs':['trng'],'words':['training']
				},
				'type':itemTypes.abbrev,
				'hash':'asdfbeqr'
			},
			'msn':{
				'dict':{
					'abbrevs':['msn','misn'],'words':['mission']
				},
				'type':itemTypes.abbrev,
				'hash':'mmmm'
			},
			'misn':{
				'dict':{
					'abbrevs':['msn','misn'],'words':['mission']
				},
				'type':itemTypes.abbrev,
				'hash':'mmmm'
			},
			'&amp;':{
				'dict':{
					'abbrevs':['&amp'],'words':['and']
				},
				'type':itemTypes.abbrev,
				'hash':'zzzzz'
			},
			'and':{
				'dict':{
					'abbrevs':['&amp;'],'words':['and']
				},
				'type':itemTypes.word,
				'hash':'zzzzz'
			}
		})
	console.log find_item_issues(found)

	html = highlight_issues(text, found)

	# result = highlight_word_acro_pairs(text_content,word_acro_data)
	return {'html':html,'issues':found} # returning: {'html': text_content, 'tooltipped_words':[]}

$ ->
	$("#input").on "input propertychange paste", ->
		#Adds the text you type in, to the output. 
		$('#output').text $('#input').val()

		console.log "***********BEGIN TO QUEEP*************"
		result = queep()
		console.log "***********CEASE TO QUEEP*************"
		$('#output').html result['html']
		# add_tooltips(result['tooltipped_words'])
		# add_tooltip_custom(".acro_green", "Approved abbreviation")
		return