// const Pump = require('../models/pump');

// exports.addPump = async (req, res) => {
//     const { name, farmId } = req.body;

//     try {
//         const pump = new Pump({ name, farmId });
//         await pump.save();
//         res.status(201).json({ message: 'Pump added successfully', pump });
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };


// exports.getPumps = async (req, res) => {
//     const { farmId } = req.params;

//     try {
//         const pumps = await Pump.find({ farmId });
//         res.status(200).json(pumps);
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };


// exports.updatePumpStatus = async (req, res) => {
//     const { pumpId } = req.params;
//     const { status, interval } = req.body;

//     try {
//         const pump = await Pump.findByIdAndUpdate(pumpId, { status, interval }, { new: true });
//         if (!pump) {
//             return res.status(404).json({ error: 'Pump not found' });
//         }
//         res.status(200).json({ message: 'Pump updated successfully', pump });
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//     }
// };
