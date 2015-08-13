module.exports = {
    restrict: function(request, response){
      response.send('This is the restricted area! Hello ' + request.session.user + '! click <a href="/logout">here to logout</a>');
    },
};