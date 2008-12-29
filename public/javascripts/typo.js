function register_onload(func) {
  Event.observe(window, 'load', func, false);
}

function show_dates_as_local_time() {
  var spans = document.getElementsByTagName('span');
  for (var i=0; i<spans.length; i++) {
    if (spans[i].className.match(/\btypo_date\b/i)) {
      spans[i].innerHTML = get_local_time_for_date(spans[i].title);
    }
  }
}

function get_local_time_for_date(time) {
  system_date = new Date(time);
  user_date = new Date();
  delta_minutes = Math.floor((user_date - system_date) / (60 * 1000));
  if (Math.abs(delta_minutes) <= (8*7*24*60)) { // eight weeks... I'm lazy to count days for longer than that
    distance = distance_of_time_in_words(delta_minutes);
    if (delta_minutes < 0) {
      return distance + ' from now';
    } else {
      return distance + ' ago';
    }
  } else {
    return 'on ' + system_date.toLocaleDateString();
  }
}

// a vague copy of rails' inbuilt function, 
// but a bit more friendly with the hours.
function distance_of_time_in_words(minutes) {
  if (minutes.isNaN) return "";
  minutes = Math.abs(minutes);
  if (minutes < 1) return ('less than a minute');
  if (minutes < 50) return (minutes + ' minute' + (minutes == 1 ? '' : 's'));
  if (minutes < 90) return ('about one hour');
  if (minutes < 1080) return (Math.round(minutes / 60) + ' hours');
  if (minutes < 1440) return ('one day');
  if (minutes < 2880) return ('about one day');
  else return (Math.round(minutes / 1440) + ' days')
}

function commentAdded(request) {
  new Effect.BlindDown($('commentList').lastChild);
  if ($('dummy_comment')) { Element.remove('dummy_comment'); }
  $('commentform').elements[3].value = '';
  $('commentform').elements[3].focus();
}

function failure(request) {
  $('errors').innerHTML = request.responseText;
  new Effect.Highlight('errors');
}

function loading() {
  $('form-submit-button').disabled = true;
  Element.show('comment_loading');
  new Element.hide('preview');
}

function complete(request) {
  Element.hide('comment_loading');
  Element.show('commentform');
  $('form-submit-button').disabled = false;  

  if (request.status == 200) { commentAdded() };  
}

register_onload(function() {
  if ($('commentform')) {
	var _author = getCookie('author');
	var _url = getCookie('url');

    if(_author != null) { $('commentform').elements['comment[author]'].value = _author }
    if(_url != null) { $('commentform').elements['comment[url]'].value = _url }
    
    if ($('commentform').elements['comment[url]'].value != ''
        || $('commentform').elements['comment[email]'].value != '') {
      Element.show('guest_url'); Element.show('guest_email');
    }
  }
})
register_onload(function() { if ($('q')) {$('q').setAttribute('autocomplete', 'off');} })