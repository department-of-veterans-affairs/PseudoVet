//var login = require();

module.exports = {
  dialog: function(req, res) {
   res.send('<form method="post" action="/login">' +
  '<p>' +
    '<label>Username:</label>' +
    '<input type="text" name="username">' +
  '</p>' +
  '<p>' +
    '<label>Password:</label>' +
    '<input type="text" name="password">' +
  '</p>' +
  '<p>' +
    '<input type="submit" value="Login">' +
  '</p>' +
  '</form>');
  },
  login: function(req, res) {
 
    var username = req.body.username;
    var password = req.body.password;
 
    if(username == 'demo' && password == 'demo'){
        req.session.regenerate(function(){
        req.session.user = username;
        res.redirect('/restricted');
        });
    }
    else {
       res.redirect('/login');
    }    
  },
  logout: function(request, response){
    request.session.destroy(function(){
        response.redirect('/');
    });
  },
};

