const mongoose = require('mongoose');

const pumpSchema = new mongoose.Schema({
    pumpId: { type: String, required: true, unique: true }, 
    farmId: { type: mongoose.Schema.Types.ObjectId, ref: 'Farm', required: true },
    status: { type: Boolean, default: false }, // true = ON, false = OFF
    interval: { type: Number, default: 0 }, // time interval in minutes
}, { timestamps: true });

module.exports = mongoose.model('Pump', pumpSchema);
