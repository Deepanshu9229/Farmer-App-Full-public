const express = require('express');
const router = express.Router();
// const bcrypt = require('bcrypt');
const Farmer = require('../../models/farmer.js');

router.post('/signup', async (req, res) => {
    const { name, city , pincode , residentialAddress } = req.body;
    const mobileNumber = req.session.mobileNumber;

    if (!name || !mobileNumber) {
        return res.status(400).json({ message: 'All fields are required.' });
    }

    try {
        const existingFarmer = await Farmer.findOne({ mobileNumber });
        if (existingFarmer) {
            return res.status(400).json({ message: 'Farmer with this mobile number already exists.' });
        }
    
        const newFarmer = new Farmer({
            name,
            mobileNumber,
            city,
            pincode ,
            residentialAddress,
        });
        await newFarmer.save();
        req.session.userId = newFarmer._id;
        req.session.mobileNumber = newFarmer.mobileNumber;

        console.log('Session after signup:', req.session);
        return res.status(201).json({ message: 'Farmer signed up successfully!' });
        
    } catch (error) {
        console.error('Error during farmer signup:', error);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

module.exports = router;
