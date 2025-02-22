const express = require('express');
const router = express.Router();
const Secretary = require('../../models/secretary');
const Farm = require('../../models/farm');

router.get('/farms', async (req, res) => {
    const secretaryId = req.session.userId;
    console.log("Secretary ID from session:", secretaryId);

    try {
        // Use findById to fetch the secretary using the ID from session.
        const secretary = await Secretary.findById(secretaryId);
        
        if (!secretary) {
            return res.status(404).json({ message: 'Secretary not found' });
        }

        const areaPinCode = secretary.areaInControl.pinCode;
        // Find farms matching the secretary's area.
        const farms = await Farm.find({ pincode: areaPinCode }).populate('farmerId'); //farm k pincode se match kr rahe 

        if (farms.length === 0) {
            return res.status(404).json({ message: 'No farms found for this area' });
        }

        // Map the results to only send required details.
        const farmDetails = farms.map(farm => ({
            farmName: farm.name,
            location: farm.location,
            farmerName: farm.farmerId ? farm.farmerId.name : 'Unknown'
        }));

        res.status(200).json(farmDetails);
    } catch (error) {
        console.error("Error fetching farms:", error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;
