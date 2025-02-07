// const Farm = require('../models/farm');

// exports.addFarm = async (req, res) => {
//     const { name, location, address } = req.body;
//     const { userId } = req.params;

//     try {
//         const farm = new Farm({ name, location, address, userId });
//         await farm.save();
//         res.status(201).json({ message: 'Farm added successfully', farm });
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };

// exports.getFarms = async (req, res) => {
//     const { userId } = req.params;

//     try {
//         const farms = await Farm.find({ userId });
//         res.status(200).json(farms);
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };
