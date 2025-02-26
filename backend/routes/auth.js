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
    console.log(`User type received: ${userType}`);
    return res.json({ message: `User type selected: ${userType}. Please enter your mobile number.` });
});

router.post('/enter-mobile', (req, res) => {
    const { mobileNumber, otp } = req.body;  // Accept otp from the client
    if (!mobileNumber) {
        return res.status(400).json({ message: 'Mobile number is required.' });
    }
    req.session.mobileNumber = mobileNumber;
    
    // Instead of generating a fixed OTP, use the one from the client
    storedOtp[mobileNumber] = otp; 
    
    return res.json({ message: `OTP sent to ${mobileNumber}. Please verify it.` }); 
});


router.post('/verify-otp', async (req, res) => {
    // Normalize userType to lowercase
    const userType = (req.session.userType || "").toLowerCase();
    const mobileNumber = req.session.mobileNumber;
    const { otp } = req.body;

    console.log("User type from session:", userType);
    console.log("Mobile number from session:", mobileNumber);
    console.log("otp from session:", otp);

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


// routes/auth.js (or a dedicated user route)
router.get('/current-user', async (req, res) => {
    const { userType, mobileNumber, userId } = req.session;
    if (!userId || !mobileNumber || !userType) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
  
    let user;
    switch (userType.toLowerCase()) {
      case 'farmer':
        user = await Farmer.findById(userId);
        break;
      case 'secretary':
        user = await Secretary.findById(userId);
        break;
      case 'admin':
        user = await Admin.findById(userId);
        break;
      default:
        return res.status(400).json({ message: 'Invalid user type' });
    }
  
    if (user) {
      return res.status(200).json(user);
    } else {
      return res.status(404).json({ message: 'User not found' });
    }
  });
  


module.exports = router;
