// /routes/secretary/secretaryRoutes.js
const express = require('express');
const router = express.Router();
const Secretary = require('../../models/secretary');
const Farm = require('../../models/farm');

router.get('/' , (req , res) => {
    res.send('Welcome to Home !');
})

router.get('/farms', async (req, res) => {
    const secretaryId = req.session.userId;

    try {
        const secretary = await Secretary.findOne(secretaryId);
        
        if (!secretary) {
            return res.status(404).json({ message: 'Secretary not found' });
        }

        const areaPinCode = secretary.areaInControl.pinCode;

        const farms = await Farm.find({ location: areaPinCode });
            // .populate('farmerId') 
            // .exec();

        if (farms.length === 0) {
            return res.status(404).json({ message: 'No farms found for this area' });
        }

        const farmDetails = farms.map(farm => ({
            farmName: farm.name,
            location: farm.location,
            farmerName: farm.farmerId.name // Accessing the populated farmer's name
        }));

        res.status(200).json(farmDetails);
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;
