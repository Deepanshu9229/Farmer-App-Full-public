const express = require('express');
const router = express.Router();
const Farm = require('../../models/farm');
const pumpRoutes = require('../farmer/pumps')

router.get('/' , async (req, res) => {
    try {
        const farms = await Farm.find({ farmerId: req.user._id }).populate('farmerId'); // req.user._id = req.userId
        res.status(200).json(farms); // display in frontend
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

router.post('/add' , async (req, res) => {   
    const { name, pincode , location, address } = req.body;

    try {
        const newFarm = new Farm({
            name,
            pincode,
            location,
            address,
            farmerId: req.user._id,
        });

        await newFarm.save();
        res.status(201).json(newFarm);
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

router.delete('/:farmId' , async(req , res) => {
    const {farmId} = req.params.farmId;

    await Farm.delete({_id : farmId});
    
})

router.use('/:farmId/pumps', pumpRoutes); 

module.exports = router;
