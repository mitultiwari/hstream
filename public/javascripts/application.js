$(function() {
  $(document).ready(loadNewItems);
  $('.item').live('click', copyIntoShortlist);
});

var mostRecentItem = 0;
function loadNewItems() {
  ajax({
    url: '/.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
    },
  });
  setTimeout(loadNewItems, 5000);

  return false;
}

var shortlist = new Object;
function copyIntoShortlist() {
  var hnid = $(this).attr('hnid');
  if (shortlist[hnid]) return true;

  $('#shortlist').prepend($(this).clone());
  shortlist[hnid] = true;
  return true;
}

function postProcess() {
  $('a').attr('target', 'blank');
}

function ajax(args) {
  $.ajax($.extend(args, {
    complete: postProcess,
  }));
}

function meths(obj) {
  var ans = [];
  for (var field in obj) {
    ans.push(field);
  }
  return ans;
}
