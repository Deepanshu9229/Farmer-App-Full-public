const express = require('express');
const router = express.Router();
const isAuthenticated = require('../../middlewares/authMiddleware');

router.get('/' , (req , res, next) => {
    console.log("currently at home !");
    res.json({ message: "Welcome to the home route!" });
});

module.exports = router;
