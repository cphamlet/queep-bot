###
highlights all items in the array passed to it

TODO: tie together elements from the same array
###
highlight_dupes = (duplicate_acronyms, text_content) ->
	for acronym_list in duplicate_acronyms
		for acronym in acronym_list
			text_content = text_content.replace ///(?<=[^a-zA-Z]|^)#{acronym}(?=([^a-zA-Z]|$))///gi,'<span class="dupe">'+acronym+'</span>'
	return text_content

highlight_typos = (typos,text_content) ->
	for typo in typos
		text_content = text_content.replace ///(?<=[^a-zA-Z]|^)#{typo}(?=([^a-zA-Z]|$))///gi,'<span class="typo">'+typo+'</span>'
	return text_content

#
# This has been changed to a pure regex version,
# this function will detect multi-words (e.g. Air Force)
#
highlight_word_acro_pairs = (text_content,word_acro_array, tooltipped_words) ->
	tooltipped_words = [];
	#For every acronym that is in the word_acro dicctionary
	for acronym in Object.keys word_acro_array
		regex_acro = ///(\b#{acronym}(?![a-zA-Z<\"=]))///gim
		#Hardcoded case for &, change in future. &amp is html encoding for "&""
		if acronym == "&amp;"
			regex_acro = ///(#{acronym})///gim
		#If the acronym is in the text
		if regex_acro.test(text_content)
			#if acronym is present in text, mark present
			acro_flag = true
			#For every possible interpretation of an acronym. i.e. 
			#Interpretation for "msn" is ["mission", "missions"]
			for spelled_word in word_acro_array[acronym]
				regex_spelled = ///(\b#{spelled_word}(?![a-zA-Z<\"=]))///gim

				#Passes true if the spelled out word is ALSO in the text_content.
				#This if statement will only be true if both the acronym AND the 
				#spelled out version is in the text. 
				if regex_spelled.test(text_content)
					acro_flag = false
					#Replace the contents

					#These are hashed because html id's 
					#cannot have invalid characters "/" or spaces
					#Cuts off last two chars, which are equal signs
					hash_pair1 = btoa(acronym+spelled_word)
					hash_pair1 = hash_pair1.slice(0,-2)
					hash_pair2 = btoa(spelled_word+acronym)
					hash_pair2 = hash_pair2.slice(0,-2)

					tooltipped_words[hash_pair1] = spelled_word
					tooltipped_words[hash_pair2] = acronym
					text_content = text_content.replace regex_acro, '<span id="'+hash_pair1+'" class="acro_pair">$&</span>'
					text_content = text_content.replace regex_spelled, '<span id="'+hash_pair2+'" class="acro_pair">$&</span>'
			if acro_flag
				text_content = text_content.replace regex_acro, '<span id="'+acronym+'" class="acro_green">$&</span>'
	return {"html":text_content, "tooltipped_words":tooltipped_words}

add_tooltip_custom = (selector, msg) ->
	tippy(selector, {content:msg,flip:false})
	return
	
add_tooltips = (tooltipped_words) ->
	for hash in Object.keys(tooltipped_words)
		add_tooltip_custom('#'+hash,"Inconsistent with: " +tooltipped_words[hash])
		add_tooltip_custom('#'+hash,"Inconsistent with: " +tooltipped_words[hash])
	return
highlight_valid_acros = (text_content, word_acro_array) ->
	acronym_array = Object.keys word_acro_array
	text_array = text_content.split(" ")
	for acro in acronym_array
		lower_word = acro.toLowerCase()
		regex = ///(\b#{acro})(?=([\n\ \!\-/\;]|$))///gim
		text_content = text_content.replace(regex,'<span id="'+acro+'" class="acro_green">$&</span>')
		
	return text_content

exclamation_check = (text_content) ->
    # This regex expression matches with an "!" that is NOT
	#followed by 2 spaces and a non-whitespace character.
	#All "!" characters must be followed by 2 spaces and a 
	#non-whitespace character
	#
	#It will not match a "!" followed by a newline character.
	regex_exclam = ///!(?!(\ \ \S)|$)///gm
	text_content = text_content.replace(regex_exclam,'<span class="invalid_exclamation">$&</span>')
	return text_content

double_dash_check = (text_content) ->
	regex_double_dash_append = ///--(?=\s)///gm
	regex_double_dash_precede = ///\s--///gm

	text_content  = text_content.replace(regex_double_dash_append,'<span class="invalid_double_dash">$&</span>')
	text_content = text_content.replace(regex_double_dash_precede,'<span class="invalid_double_dash">$&</span>')
	
	return text_content


tooltipped_words = {}
queep = ->
	text_content = $('#output').html()
	result = highlight_word_acro_pairs(text_content,word_acro_data, tooltipped_words)
	text_content = result['html']
	text_content = exclamation_check(text_content)
	text_content = double_dash_check(text_content)
	result['html'] = text_content
	return result # returning: {'html': text_content, 'tooltipped_words':[]}

$ ->
	
	$("#input").on "input propertychange paste", ->
		#Adds the text you type in, to the output. 
		$('#output').text $('#input').val()

		result = queep()
		$('#output').html result['html']
		add_tooltips(result['tooltipped_words'])
		add_tooltip_custom(".acro_green", "Approved abbreviation")
		add_tooltip_custom(".invalid_double_dash", "Error: Whitespace next to '--'")
		add_tooltip_custom(".invalid_exclamation", "2 spaces must appear after a '!'")
		return