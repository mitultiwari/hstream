$(function() {
  $(document).ready(loadNewItems);
});

var mostRecentItem = 0;
function loadNewItems() {
  $.ajax({
    url: '/.js',
    method: 'get',
    parameters: {
      mostRecentItem: mostRecentItem,
    },
  });
  setTimeout(loadNewItems, 5000);

  return false;
}
