var mysql = require('mysql2');
var conn = mysql.createConnection({
    host: 'localhost', 
    user: 'root',      
    password: 'my-secret-pw',      
    database: 'db_prueba31082022' 
}); 

conn.connect(function(err) {
    if (err) throw err;
    console.log('Database is connected successfully !');
});
module.exports = conn;