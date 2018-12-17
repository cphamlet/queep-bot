#
# This has been changed to a pure regex version,
# this function will detect multi-words (e.g. Air Force)
#
highlight_word_acro_pairs = (text_content,word_acro_array) ->
	# esc = RegExp('&#x[A-F0-9]{1,4};(?!<)', "gim");
	# text_content = text_content.replace esc, '<span class="unicode">$&</span>'
	tooltipped_words = [];
	approved_acros = [];
	#For every acronym that is in the word_acro dicctionary
	for acronym in Object.keys word_acro_array
		regex_acro = RegExp('(\\b' + acronym + '(?![a-zA-Z<"=\\\']))', "gim"); 
		#Hardcoded case for &, change in future. &amp is html encoding for "&"" 
		#TODO, remove this
		if acronym == "&"
			regex_acro = RegExp('(' + acronym + ')', "gim");
		#If the acronym is in the text
		if regex_acro.test(text_content)
			#if acronym is present in text, mark present
			acro_flag = true
			#For every possible interpretation of an acronym. i.e. 
			#Interpretation for "msn" is ["mission", "missions"]
			for spelled_word in word_acro_array[acronym]
				regex_spelled = RegExp('(\\b' + spelled_word + '(?![a-zA-Z<"=\\\']))', "gim"); #Passes true if the spelled out word is ALSO in the text_content.

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
				acro_id = btoa(acronym).slice(0,-2)
				text_content = text_content.replace regex_acro, '<span id="'+acro_id+'" class="approved_acro">$&</span>'
				approved_acros[acro_id] = acronym
	return {"html":text_content, "tooltipped_words":tooltipped_words, "approved_acros":approved_acros}

add_tooltip_custom = (selector, msg) ->
	tippy(selector, {content:msg,flip:false})
	return
	
add_tooltips = (tooltipped_words) ->
	for hash in Object.keys(tooltipped_words)
		add_tooltip_custom('#'+hash,"Inconsistent with: " +tooltipped_words[hash])
	return
highlight_valid_acros = (text_content, word_acro_array) ->
	acronym_array = Object.keys word_acro_array
	text_array = text_content.split(' ')
	for acro in acronym_array
		lower_word = acro.toLowerCase()
		regex = RegExp('(\\b' + acro + ')(?=([\\n \\!\\-/\\;]|$))', "gim");
		text_content = text_content.replace(regex,'<span id="'+acro+'" class="approved_acro">$&</span>')
		
	return text_content

exclamation_check = (text_content) ->
    # This regex expression matches with an "!" that is NOT
	#followed by 2 spaces and a non-whitespace character.
	#All "!" characters must be followed by 2 spaces and a 
	#non-whitespace character
	#
	#It will not match a "!" followed by a newline character.
	regex_exclam = ///!(?!(\ \ \S)|\ {0,}$)///gm
	text_content = text_content.replace(regex_exclam,'<span class="invalid_exclamation">$&</span>')
	return text_content

double_dash_check = (text_content) ->
	regex_double_dash_append = ///--(?=\s)///gm
	regex_double_dash_precede = ///\s--///gm

	text_content  = text_content.replace(regex_double_dash_append,'<span class="invalid_double_dash">$&</span>')
	text_content = text_content.replace(regex_double_dash_precede,'<span class="invalid_double_dash">$&</span>')
	
	return text_content

#Semi-colon must have exactly 1 space after it
semi_colon_space_check = (text_content) ->
	regex_exclam = ///;(?!(\ \S)|\ {0,}$)///gm
	text_content = text_content.replace(regex_exclam,'<span class="invalid_semi_colon">$&</span>')
	return text_content

queep = ->
	text_content = $('#output').text()
	result = highlight_word_acro_pairs(text_content,word_acro_data)

	text_content = result['html']
	text_content = exclamation_check(text_content)
	text_content = double_dash_check(text_content)
	text_content = semi_colon_space_check(text_content)
	result['html'] = text_content
	return result # returning: {'html': text_content, 'tooltipped_words':[], 'approved_acros':[]}

$ ->
	
	$("#input-text").on "input propertychange paste", ->
		#Adds the text you type in, to the output. 
		$('#output').text $('#input-text').val()
		result = queep()
		$('#output').html result['html']
		add_tooltips(result['tooltipped_words'])


		approved_acros = result['approved_acros']
		#For every approved acronym, reveal the spelled word in the UI
		for acro_elem in Object.keys(approved_acros)
			add_tooltip_custom("#"+acro_elem, "Abbreviates to: "+word_acro_data[approved_acros[acro_elem]][0])
		
		
		add_tooltip_custom(".invalid_double_dash", "Error: Whitespace next to '--'")
		add_tooltip_custom(".invalid_exclamation", "A '!' must have exactly 2 spaces after it")
		add_tooltip_custom(".invalid_semi_colon", "A ';' must have exactly 1 space after it")
		return


