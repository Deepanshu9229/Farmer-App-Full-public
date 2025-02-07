const express = require('express');
const router = express.Router();
// const bcrypt = require('bcrypt');
const Secretary = require('../../models/secretary.js');

router.post('/signup', async (req, res) => {
    const { name , city , pincode , residentialAddress } = req.body;
    const mobileNumber = req.session.mobileNumber;

    if (!name || !mobileNumber ) {
        return res.status(400).json({ message: 'All fields are required.' });
    }

    try {
        const existingSecretary = await Secretary.findOne({ mobileNumber });
        if (existingSecretary) {
            return res.status(400).json({ message: 'Secretary with this mobile number already exists.' });
        }
    
        const newSecretary = new Secretary({
            name,
            mobileNumber,
            city,
            pincode ,
            residentialAddress,
        });
        await newSecretary.save();
        req.session.userId = newSecretary._id;
        req.session.mobileNumber = newSecretary.mobileNumber;

        console.log('Session after signup:', req.session);
        return res.status(201).json({ message: 'Farmer signed up successfully!' });
        
    } catch (error) {
        console.error('Error during signup:', error);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

module.exports = router;
