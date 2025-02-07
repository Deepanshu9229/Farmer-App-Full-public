const express = require('express');

const isAuthenticated = (req, res, next) => {
    if (req.session.mobileNumber && req.session.userId) {
        req.user = { _id: req.session.userId }; // Attach user object
        return next(); 
    }
    else{
        return res.status(401).json({ message: 'Unauthorized: Please log in.' });
    }
};

module.exports = isAuthenticated;

