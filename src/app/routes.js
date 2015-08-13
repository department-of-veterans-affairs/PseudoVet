var home = require('../controllers/home'),
    login = require('../controllers/login'),
    contacts = require('../controllers/contacts');
    restrict = require('../controllers/restrict');

module.exports.initialize = function(app) {
    //app.get('/login', login.dialog);
    //app.post('/login', login.login);
    //app.get('/logout', login.logout);

    //app.get('/', home.index);
    app.get('/', login.dialog);
    app.post('/login', login.login);
    app.get('/logout', login.logout);
    
    app.get('/api/contacts', contacts.index);
    app.get('/api/contacts/:id', contacts.getById);
    app.post('/api/contacts', contacts.add);
    // app.put('/api/contacts', contacts.update);
    app.delete('/api/contacts/:id', contacts.delete);
    app.get('/restricted', restrict.restrict);
};

 
 

