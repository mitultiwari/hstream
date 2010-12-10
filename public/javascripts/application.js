function setupPage() {
  loadNewItems();
  setTimeout(setupPage, 5000); // keep sync'd with crawler RECENCY_THRESHOLD
}

function loadNewItems() {
  $.ajax({
    url: '/root.json',
    method: 'get',
    success: function(response) {
      alert(response);
    },
  });
}
