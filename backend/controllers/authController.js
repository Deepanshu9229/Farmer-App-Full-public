// const User = require('../models/User');

// exports.signup = async (req, res) => {
//     const { mobileNumber, userType } = req.body;

//     try {
//         const user = new User({ mobileNumber, userType });
//         await user.save();
//         res.status(201).json({ message: 'User registered successfully', user });
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };

