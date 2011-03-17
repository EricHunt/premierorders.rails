var CatalogOrder = function() {
  var instance = {
    storage_root:       'net.premierorders',
    order_storage_root: 'net.premierorders.orders',
    find_order: function(id) {
      var data = localStorage[this.order_storage_root+"."+id];  
      return (data ? JSON.parse(data) : undefined);
    },
    save_local: function(order_data) {
      localStorage[this.order_storage_root+"."+order_data.id] = JSON.stringify(order_data);
    },
    remove_local: function(order_data) {
      localStorage[this.order_storage_root+"."+order_data.id] = undefined;
    },
    place: function(order_data) {
      $.loading({ mask:true });
      $.ajax({
        url: "/catalog_orders",
        type: "POST",
        data: order_data,
        success: function(order_placed_data) {
          if (order_placed_data["updated"] == "success") {
            instance.remove_local(order_data);
            window.location = "/jobs/" + order_placed_data['job_id'];
          } else {
            alert("There was an error in order placement. Please notify an administrator.");
          }
          $.loading();
        },
        error: function(jqXHR, textStatus, errorThrown) {
          if (supports_local_storage()) {
            instance.save_local(order_data);
            alert("You appear to be offline, so your order has been placed into local storage for submission when you reconnect. Thanks!");
          } else {
            alert("We're sorry; it appears that your are offline and that your browser doesn't support local storage. Please connect to the internet to use the catalog ordering functionality.");
          }

          window.location = "/offline.html";
        },
        dataType: "json"
      });
    }
  };

  return instance;
}();


