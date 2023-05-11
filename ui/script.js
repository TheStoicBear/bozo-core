window.addEventListener("message", function (event) {
    switch(event.data.action) {
        default:
            notify(event.data);
            break;  
    }
});

function notify(data) {
    var $notification = $(".notification.template").clone();
    $notification.removeClass("template");
    $notification.addClass(data.type);
    $notification.html(data.text);
    $notification.fadeIn();
    $(".notif-container").append($notification);
    setTimeout(function() {
        $.when($notification.fadeOut()).done(function() {
            $notification.remove()
        });
    }, data.length === undefined ? data.length : 5000);
}