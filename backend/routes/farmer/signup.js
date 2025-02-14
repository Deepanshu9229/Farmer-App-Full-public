const express = require('express');
const router = express.Router();
const Farmer = require('../../models/farmer.js');

router.post('/signup', async (req, res) => {
    const { name, mobileNumber, city, pincode, residentialAddress } = req.body;

    if (!name || !mobileNumber) {
        return res.status(400).json({ message: 'All fields are required.' });
    }

    try {
        const existingFarmer = await Farmer.findOne({ mobileNumber });
        if (existingFarmer) {
            return res.status(400).json({ message: 'Farmer with this mobile number already exists.' });
        }
    
        const newFarmer = new Farmer({ name, mobileNumber, city, pincode, residentialAddress });
        const savedFarmer = await newFarmer.save();
        console.log("New Farmer ID: ", savedFarmer._id);
        

        return res.status(201).json({ message: 'Farmer signed up successfully!' });
    } catch (error) {
        console.error('Error during signup:', error);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

module.exports = router;
