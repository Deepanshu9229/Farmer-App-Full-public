// const Farmer = require('../models/farmer');
// const Secretary = require('../models/secretary');

// exports.getAllFarmers = async (req, res) => {
//     try {
//         const farmers = await Farmer.find().populate('lands');
//         res.status(200).json(farmers);
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };

// exports.getAllSecretaries = async (req, res) => {
//     try {
//         const secretaries = await Secretary.find(); 
//         res.status(200).json(secretaries);
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };
