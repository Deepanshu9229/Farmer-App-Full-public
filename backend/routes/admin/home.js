const express = require('express');
const router = express.Router();
const Farmer = require('../../models/farmer')
const Farms = require('../../models/farm');
const Secretary = require('../../models/secretary');

router.get('/home' , (req , res) => {
    res.send('Welcome to Home !');
})

// router.get('/farmers', async (req, res) => {
//     try {
//         const farmers = await Farmer.find();
//         res.status(200).json(farmers);
//     } catch (error) {
//         res.status(500).json({ error: 'Internal server error' });
//     }
// });

router.get('/secretaries/:secretaryId/farms', async (req, res) => {
    const secretaryId = req.params.id;

    try {
        // Find the secretary to get their area control information
        const secretary = await Secretary.findOne({_id : secretaryId});
        
        if (!secretary) {
            return res.status(404).json({ message: 'Secretary not found' });
        }

        const areaPinCode = secretary.areaInControl.pinCode; 

        const farms = await Farmer.find({ 'pincode': areaPinCode });

        if (farms.length === 0) {
            return res.status(404).json({ message: 'No farms found under this secretary\'s area' });
        }

        res.status(200).json(farms);
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});
module.exports = router;
