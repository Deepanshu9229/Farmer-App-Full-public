const express = require('express');
const router = express.Router();
const Secretary = require('../../models/secretary.js');

router.post('/signup', async (req, res) => {
    const { name, city, pincode, residentialAddress, areaInControl } = req.body;
    // Retrieve mobileNumber from session (set during OTP flow)
    const mobileNumber = req.session.mobileNumber;
    console.log("Mobile number from session in signup route:", mobileNumber);
    
    // Validate that all required fields are provided.
    if (!name || !mobileNumber || !city || !pincode || !residentialAddress || !areaInControl) {
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
            pincode,
            residentialAddress,
            areaInControl: {
                pinCode: areaInControl.pinCode,
                areaName: areaInControl.areaName,
            },
        });
        const savedSecretary = await newSecretary.save();
        // Update session data after signup.
        req.session.userId = savedSecretary._id;
        req.session.mobileNumber = savedSecretary.mobileNumber;

        console.log('Session after signup:', req.session);
        return res.status(201).json({ 
          message: 'Secretary signed up successfully!', 
          secretaryId: savedSecretary._id 
        });
    } catch (error) {
        console.error('Error during signup:', error);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

module.exports = router;
