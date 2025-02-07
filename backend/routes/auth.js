const express = require('express');
const router = express.Router();
const Farmer = require('../models/farmer'); 
const Secretary = require('../models/secretary');
const Admin = require('../models/admin'); 

const sendOtp = (mobileNumber) => {
    console.log(`Sending OTP to ${mobileNumber}`);
    return '123456'; 
};

// In-memory storage for OTPs (use a database in production)
let storedOtp = {}; 

router.post('/select-user-type', (req, res) => {
    const { userType } = req.body;
    if (!userType) {
        return res.status(400).json({ message: 'User type is required.' });
    }
    req.session.userType = userType; 
    return res.json({ message: `User type selected: ${userType}. Please enter your mobile number.` });
});

router.post('/enter-mobile', (req, res) => {
    const { mobileNumber } = req.body;
    // const userType = req.session.userType;
    req.session.mobileNumber = mobileNumber;
    if (!mobileNumber) {
        return res.status(400).json({ message: 'Mobile number is required.' });
    }

    const otpToSend = sendOtp(mobileNumber);
    storedOtp[mobileNumber] = otpToSend; 
    return res.json({ message: `OTP sent to ${mobileNumber}. Please verify it.` });
});

router.post('/verify-otp', async (req, res) => {
    const userType = req.session.userType;
    const mobileNumber = req.session.mobileNumber;
    const { otp } = req.body;

    if (!mobileNumber || !otp) {
        return res.status(400).json({ message: 'Mobile number and OTP are required.' });
    }

    if (storedOtp[mobileNumber] && otp === storedOtp[mobileNumber]) {
        delete storedOtp[mobileNumber]; 

        let user;
        switch (userType) {
            case 'farmer':
                user = await Farmer.findOne({ mobileNumber });
                break;
            case 'secretary':
                user = await Secretary.findOne({ mobileNumber });
                break;
            case 'admin':
                user = await Admin.findOne({ mobileNumber });
                break;
            default:
                return res.status(400).json({ message: 'Invalid user type.' });
        }

        if (user) {
            req.session.userId = user._id;
            req.session.mobileNumber = user.mobileNumber;
            return res.json({ redirectUrl: `/api/${userType}/home` });
        } else {
            return res.json({ redirectUrl: `/api/${userType}/signup` });
        }     
    } else {
        return res.status(400).json({ message: 'Invalid OTP' });
    }
});

module.exports = router;
