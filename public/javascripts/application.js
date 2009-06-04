// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function sf(){

    if( $( "login_username" ) ) {
		var x = $( "login_username" );
		
		if (x.value != "") {
			var y = $( "login_password" );
			y.focus();
		} else {
			x.focus();
		}
    } 

}


function go(type, id) {

	var base = '/abstracts/';
	
	if (type == 'program') {
		base += 'program/';
	} else if (type == 'member') {
		base += 'member/';
	} else {
		base += 'year/';
	}
	
	if (id) location.href = base + id;
 
}


function toggle_abstract(link, abstract_id) {
	
	abstract = 'abstract_' + abstract_id
	
	if (Element.visible(abstract)) {
		Effect.BlindUp(abstract, { duration: 0.5 })
		link.innerHTML = "Show Abstract"
		
		
	} else {
		Effect.BlindDown(abstract, { duration: 0.5 })
		link.innerHTML = "Hide Abstract"
	}
	
	return false;
}

function toggle_abstract_all(link) {
	
	if (link.innerHTML == 'Show Abstracts') {
		link.innerHTML = 'Hide Abstracts'
	} else {
		link.innerHTML = 'Show Abstracts'
	}
	
	//window.location(link_to);
	
	$$('div.abstract_print').each(Element.toggle); return false;

}
