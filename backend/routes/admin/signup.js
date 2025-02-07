const express = require('express');
const router = express.Router();
// const bcrypt = require('bcrypt');
const Admin= require('../../models/admin.js');

router.post('/signup', async (req, res) => {
    const { name , city , pincode , residentialAddress } = req.body;
    const mobileNumber = req.session.mobileNumber;

    if (!name || !mobileNumber ) {
        return res.status(400).json({ message: 'All fields are required.' });
    }

    try {
        const existingAdmin = await Admin.findOne({ mobileNumber });
        if (existingAdmin) {
            return res.status(400).json({ message: 'Secretary with this mobile number already exists.' });
        }
    
        const newAdmin = new Admin({
            name,
            mobileNumber,
            city,
            pincode ,
            residentialAddress,
        });
        await newAdmin.save();
        req.session.userId = newAdmin._id;
        req.session.mobileNumber = newAdmin.mobileNumber;

        console.log('Session after signup:', req.session);
        return res.status(201).json({ message: 'Admin signed up successfully!' });
        
    } catch (error) {
        console.error('Error during signup:', error);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

module.exports = router;
