const express = require('express');
const router = express.Router();

const home = require('./home');
const farmRoutes = require('./farms');
const pumpRoutes = require('./pumps');

router.use('/home', home);         
router.use('/farms', farmRoutes);    
router.use('/:farmId/pumps', pumpRoutes);
// router.use('/pump', pumpRoutes);        

module.exports = router;
