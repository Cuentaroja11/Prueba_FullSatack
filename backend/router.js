const express = require('express');
const router = express.Router();
const db  = require('./dbConnection');
const { signupValidation, loginValidation } = require('./validation');
const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

router.post('/DELLAREA', (req, res, next) => {
    db.query(`CALL DELLAREA(${db.escape(req.body.usuario)}, ${db.escape(req.body.area)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.post('/ADDAREA', (req, res, next) => {
    db.query(`CALL ADDAREA(${db.escape(req.body.usuario)}, ${db.escape(req.body.area)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.post('/DELLOGRO', (req, res, next) => {
    db.query(`CALL DELLOGRO(${db.escape(req.body.usuario)}, ${db.escape(req.body.titulo)}, ${db.escape(req.body.year)}, 
    ${db.escape(req.body.institucion)}, ${db.escape(req.body.info)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
})

router.post('/ADDLOGRO', (req, res, next) => {
    db.query(`CALL ADDLOGRO(${db.escape(req.body.usuario)}, ${db.escape(req.body.titulo)}, ${db.escape(req.body.year)}, 
    ${db.escape(req.body.institucion)}, ${db.escape(req.body.info)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
})

router.post('/UDP', (req, res, next) => {
    db.query(`CALL UDP(${db.escape(req.body.nombre)}, ${db.escape(req.body.apellido)}, ${db.escape(req.body.tel)}, 
    ${db.escape(req.body.dir)}, ${db.escape(req.body.fecha)}, ${db.escape(req.body.dato)}, ${db.escape(req.body.usuario)}, 
    ${db.escape(req.body.pass)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.post('/LOGUIN', (req, res, next) => {
    db.query(`CALL LOGUIN(${db.escape(req.body.usuario)}, ${db.escape(req.body.pass)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.post('/REGISTRO', (req, res, next) => {
    db.query(`CALL REGISTRO(${db.escape(req.body.nombre)}, ${db.escape(req.body.apellido)}, ${db.escape(req.body.tel)}, 
    ${db.escape(req.body.dir)}, ${db.escape(req.body.fecha)}, ${db.escape(req.body.dato)}, ${db.escape(req.body.usuario)}, 
    ${db.escape(req.body.pass)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.post('/ADDAREA', (req, res, next) => {
    db.query(`CALL ADDAREA(${db.escape(req.body.usuario)}, ${db.escape(req.body.area)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.post('/DELLAREA', (req, res, next) => {
    db.query(`CALL DELLAREA(${db.escape(req.body.usuario)}, ${db.escape(req.body.area)});`, function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.get('/CONSAREAS', (req, res, next) => {
    db.query("CALL CONSAREAS();", function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.get('/CONSGRADO', (req, res, next) => {
    db.query("CALL CONSGRADO();", function (err, result, fields) {
        if (err) throw err;
        console.log(result);
        return res.status(400).send({
            msg: result
        });
    });
});

router.post('/login', loginValidation, (req, res, next) => {
db.query(
    `SELECT * FROM users WHERE email = ${db.escape(req.body.email)};`,
    (err, result) => {
      // user does not exists
    if (err) {
        throw err;
        return res.status(400).send({
        msg: err
        });
    }
    if (!result.length) {
        return res.status(401).send({
        msg: 'Email or password is incorrect!'
        });
    }
      // check password
    bcrypt.compare(
        req.body.password,
        result[0]['password'],
        (bErr, bResult) => {
          // wrong password
        if (bErr) {
            throw bErr;
            return res.status(401).send({
            msg: 'Email or password is incorrect!'
            });
        }
        if (bResult) {
            const token = jwt.sign({id:result[0].id},'the-super-strong-secrect',{ expiresIn: '1h' });
            db.query(
            `UPDATE users SET last_login = now() WHERE id = '${result[0].id}'`
            );
            return res.status(200).send({
            msg: 'Logged in!',
            token,
            user: result[0]
            });
        }
        return res.status(401).send({
            msg: 'Username or password is incorrect!'
        });
        }
    );
    }
);
});

module.exports = router;